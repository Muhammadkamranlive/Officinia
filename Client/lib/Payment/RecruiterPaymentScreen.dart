import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:chargily_pay/chargily_pay.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/PaymentConfig.dart';
import 'package:client/Server/Model/PaymentStatus.dart';
import 'package:client/Server/Repo/PaymentConfigRepository.dart';
import 'package:client/Server/Repo/PaymentRepository.dart';
import 'package:client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';

class RecruiterPaymentScreen extends StatefulWidget {
  const RecruiterPaymentScreen({super.key});

  @override
  State<RecruiterPaymentScreen> createState() => _RecruiterPaymentScreenState();
}

class _RecruiterPaymentScreenState extends State<RecruiterPaymentScreen> {
  // ── Repos ──────────────────────────────────────────────────────────────────
  final _paymentRepo = PaymentRepository();
  final _paymentConfigRepo = PaymentConfigRepository();
  final _appLinks = AppLinks();

  // ── State ──────────────────────────────────────────────────────────────────
  PaymentConfig? _config;
  PaymentModel? _activeSubscription;
  List<PaymentModel> _history = [];
  bool _loading = true;
  bool _paying = false;

  // ── Subscriptions ──────────────────────────────────────────────────────────
  StreamSubscription<Uri>? _linkSub;
  StreamSubscription<List<PaymentModel>>? _paymentSub;

  // ── Track previous active state to detect new activation ──────────────────
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _loadConfig(); // load config once
    _listenToPayments(); // stream handles payment state live
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _paymentSub?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    // Handle app opened FROM a link (cold start)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri);
    });

    // Handle link while app is running (warm start)
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (mounted) _handleUri(uri);
    });
  }

  // ── Load config only (payments come via stream) ────────────────────────────
  Future<void> _loadConfig() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final config = await _paymentConfigRepo.get();

    if (!mounted) return;
    setState(() {
      _config = config;
      _loading = false;
    });
  }

  void _handleUri(Uri uri) {
    final path = uri.path.toLowerCase();
    final isFailure = path.contains('failure');
    final isSuccess = path.contains('success');

    if (isFailure) {
      _onPaymentFailure();
    } else if (isSuccess) {
      _onPaymentSuccess();
    }
  }

  // ── Live stream for payments ───────────────────────────────────────────────
  void _listenToPayments() {
    final userId = context.read<AuthProvider>().user?.userId;
    if (userId == null) return;

    _paymentSub = _paymentRepo.streamForRecruiter(userId).listen((payments) {
      if (!mounted) return;

      final paid = payments
          .where((p) => p.status == PaymentStatus.paid)
          .toList();

      // Most recent active subscription
      final active = paid.isNotEmpty
          ? paid.reduce((a, b) => a.expiresAt.isAfter(b.expiresAt) ? a : b)
          : null;

      // ✅ Auto-detect new payment activation
      if (active != null && !_wasActive) {
        _wasActive = true;
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          showCustomToast(
            _config?.testMode == true
                ? l10n.payment_test_success_toast
                : l10n.payment_success_toast,
            context,
          );
        }
      }

      if (active == null) _wasActive = false;

      setState(() {
        _activeSubscription = active;
        _history = paid;
        _paying = false; // stop spinner once stream confirms
      });
    });
  }

  Future<void> _onPaymentSuccess() async {
    if (!mounted) return;

    // ✅ Close Safari/Chrome Custom Tab immediately
    await closeCustomTabs();

    // setState(() => _paying = true);
    // await Future.delayed(const Duration(seconds: 3));
    // if (mounted && _activeSubscription == null) {
    //   showCustomToast('Payment received. Your plan will activate shortly.', context);
    //   setState(() => _paying = false);
    // }
  }

  Future<void> _onPaymentFailure() async {
    if (!mounted) return;

    // ✅ Close Safari/Chrome Custom Tab immediately
    await closeCustomTabs();

    // setState(() => _paying = false);
    // _showError('Payment was not completed. Please try again.');
  }

  // ── Start payment ──────────────────────────────────────────────────────────
  Future<void> _startPayment() async {
    final cfg = _config;
    final user = context.read<AuthProvider>().user;
    if (cfg == null || user == null) return;
    if (!mounted) return;
    setState(() => _paying = true);

    try {
      final endpoint = cfg.testMode
          ? 'https://pay.chargily.net/test/api/v2/checkouts'
          : cfg.cloudFunctionUrl;

      final apiResponse = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer ${cfg.testSecretKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': cfg.annualFee,
          'currency': cfg.currency,
          'success_url': cfg.successUrl,
          'failure_url': cfg.failureUrl,
          'locale': cfg.locale,
          'webhook_endpoint': cfg.webhookUrl,
          'description':
              'Pharmacy Job Listing ${DateTime.now().year} — Ophicina',
          'metadata': {'recruiterId': user.userId, 'year': DateTime.now().year},
        }),
      );

      final l10n = AppLocalizations.of(context)!;

      if (apiResponse.statusCode != 200 && apiResponse.statusCode != 201) {
        if (mounted)
          _showError(
            l10n.submit_listing_request_error,
          );
        setState(() => _paying = false);
        return;
      }

      final json = jsonDecode(apiResponse.body) as Map<String, dynamic>;
      Checkout checkout = Checkout.fromJson(json);
      checkout = checkout.copyWith(
        checkoutUrl: checkout.checkoutUrl.replaceFirst('http://', 'https://'),
      );

      await _paymentRepo.add(
        PaymentModel(
          recruiterId: user.userId,
          checkoutId: checkout.id,
          amount: cfg.annualFee,
          year: DateTime.now().year,
          status: PaymentStatus.pending,
          paymentMethod: 'unknown',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      if (!mounted) return;
      setState(() => _paying = false);

      await launchUrl(
        Uri.parse(checkout.checkoutUrl),
        customTabsOptions: const CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes(
            colorScheme: CustomTabsColorScheme.light,
          ),
          showTitle: true,
          urlBarHidingEnabled: true,
          shareState: CustomTabsShareState.off,
          instantAppsEnabled: false,
        ),
        safariVCOptions: const SafariViewControllerOptions(
          preferredBarTintColor: Colors.white,
          preferredControlTintColor: Colors.black,
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } on ChargilyNetworkException {
      if (mounted)
        _showError(AppLocalizations.of(context)!.payment_connection_error);
    } on ChargilyApiException catch (e) {
      if (mounted)
        _showError(
            AppLocalizations.of(context)!.listing_request_failed_error(e.message));
    } on http.ClientException {
      if (mounted)
        _showError(AppLocalizations.of(context)!.listing_service_unreachable_error);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.payment_generic_error);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    final isTestMode = cfg?.testMode ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            // AFTER
            Text(
              AppLocalizations.of(context)!.post_job_appbar_title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (isTestMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  AppLocalizations.of(context)!.test_mode_badge,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadConfig,
              color: AppColors.green,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Payment pending indicator
                    if (_paying) ...[
                      _payingBanner(),
                      const SizedBox(height: 16),
                    ],
                    if (isTestMode) ...[
                      _testModeBanner(),
                      const SizedBox(height: 16),
                    ],
                    _statusCard(),
                    const SizedBox(height: 24),
                    if (_activeSubscription == null) _subscribeCard(),
                    if (_history.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _historySection(),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Paying banner ──────────────────────────────────────────────────────────
  Widget _payingBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.submitting_listing_request_banner,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Test mode banner ───────────────────────────────────────────────────────
  Widget _testModeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.test_mode_banner_title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.test_card_details_label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 4),
                _TestCardRow(
                  label: AppLocalizations.of(context)!.test_card_number_label,
                  value: '0000 0000 0000 0000',
                ),
                _TestCardRow(
                    label: AppLocalizations.of(context)!.test_card_expiry_label,
                    value: AppLocalizations.of(context)!.test_card_future_date_label),
                _TestCardRow(
                    label: AppLocalizations.of(context)!.test_card_otp_label,
                    value: '0000'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Status card ────────────────────────────────────────────────────────────
  Widget _statusCard() {
    final cfg = _config;
    final isActive = _activeSubscription != null;
    final daysLeft = isActive
        ? _activeSubscription!.expiresAt.difference(DateTime.now()).inDays
        : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isActive
            ? AppColors.gradientgreen
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade200],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isActive ? AppColors.green : Colors.grey).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? AppLocalizations.of(context)!.active_plan_label
                          : AppLocalizations.of(context)!.no_active_plan_label,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isActive
                          ? AppLocalizations.of(context)!
                              .annual_job_listing_title(_activeSubscription!.year)
                          : AppLocalizations.of(context)!.list_vacancy_hint_subtitle,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              children: [
                _statPill(
                  icon: Icons.calendar_today_outlined,
                  label: AppLocalizations.of(context)!.payment_expires_label,
                  value: DateFormat(
                    'dd MMM yyyy',
                  ).format(_activeSubscription!.expiresAt),
                ),
                const SizedBox(width: 10),
                _statPill(
                  icon: Icons.hourglass_bottom_rounded,
                  label: AppLocalizations.of(context)!.payment_days_left_label,
                  value: AppLocalizations.of(context)!
                      .payment_days_count(daysLeft),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statPill(
                  icon: Icons.payments_outlined,
                  label: AppLocalizations.of(context)!.payment_paid_label,
                  value:
                      '${_activeSubscription!.amount.toStringAsFixed(0)} DZD',
                ),
                const SizedBox(width: 10),
                _statPill(
                  icon: Icons.credit_card_outlined,
                  label: AppLocalizations.of(context)!.payment_method_label,
                  value: _methodLabel(
                      context, _activeSubscription!.paymentMethod),
                ),
              ],
            ),
            if (daysLeft <= 30) ...[
              const SizedBox(height: 16),
              _warningBanner(
                AppLocalizations.of(context)!
                    .listing_expires_warning_banner(daysLeft),
              ),
              const SizedBox(height: 12),
              _renewButton(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _statPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 15),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _warningBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subscribeCard() {
    final cfg = _config ?? PaymentConfig.defaults();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.green,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cfg.planName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      cfg.planSubtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (cfg.planDescription.isNotEmpty) ...[
            Text(
              cfg.planDescription,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
          ...cfg.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: AppColors.green, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _subscribeButton(),
          const SizedBox(height: 14),
          if (cfg.disclaimer.isNotEmpty)
            Text(
              cfg.disclaimer,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _subscribeButton() {
    return SizedBox(
      width: double.infinity,
      child: _paying
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradientgreen,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _startPayment,
                icon: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  AppLocalizations.of(context)!.list_pharmacy_vacancy_btn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _renewButton() {
    return SizedBox(
      width: double.infinity,
      child: _paying
          ? const Center(child: CircularProgressIndicator())
          : OutlinedButton.icon(
              onPressed: _startPayment,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.list_another_vacancy_btn),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }

  Widget _historySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.job_posting_history_title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._history.map(_historyTile),
      ],
    );
  }

  Widget _historyTile(PaymentModel p) {
    final isTestMode = _config?.testMode ?? false;
    final planName = _config?.planName ?? 'Pharmacy Job Listing';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$planName · ${p.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isTestMode) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TEST',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(p.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _methodLabel(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case 'edahabia':
        return l10n.payment_method_edahabia;
      case 'cib':
        return l10n.payment_method_cib;
      default:
        return l10n.payment_method_unknown;
    }
  }
}

// ── Test card row ─────────────────────────────────────────────────────────────
class _TestCardRow extends StatelessWidget {
  final String label;
  final String value;
  const _TestCardRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
