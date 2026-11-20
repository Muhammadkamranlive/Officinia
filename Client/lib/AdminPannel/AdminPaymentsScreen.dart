
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/PaymentStatus.dart';
import 'package:client/Server/Repo/PaymentRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final _paymentRepo   = PaymentRepository();
  final _recruiterRepo = RecruiterRepository();

  List<PaymentEntry> _entries = [];
  bool _loading = true;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final payments = await _paymentRepo.getByStatus(PaymentStatus.paid);
    final entries  = await Future.wait(
      payments.map((p) async {
        final recruiter = await _recruiterRepo.getByUid(p.recruiterId);
        return PaymentEntry(payment: p, recruiter: recruiter);
      }),
    );
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  double get _totalRevenue =>
      _entries.fold(0, (sum, e) => sum + e.payment.amount);

  int get _activeCount =>
      _entries.where((e) => e.payment.isActive).length;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // ✅ Web: cap at 860px. Mobile: full width, no change.
    final double maxWidth =
        kIsWeb ? (size.width > 920 ? 860.0 : size.width) : size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title:  Text(
          AppLocalizations.of(context)!.paidSubscriptions,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.noPaidSubscriptions,
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.green,
                  // ✅ Center content on web, full width on mobile
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: maxWidth,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _StatsBar(
                              total: _entries.length,
                              active: _activeCount,
                              revenue: _totalRevenue,
                            ),
                          ),
                          // ✅ Web wide: 2-column card grid. Mobile: original single column.
                          kIsWeb && size.width > 700
                              ? SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 32),
                                  sliver: _WebTwoColumnList(
                                    entries: _entries,
                                    expandedIndex: _expandedIndex,
                                    onTap: (i) => setState(() =>
                                        _expandedIndex =
                                            _expandedIndex == i ? null : i),
                                  ),
                                )
                              : SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 32),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (_, i) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _PaymentCard(
                                          entry: _entries[i],
                                          isExpanded: _expandedIndex == i,
                                          onTap: () => setState(() =>
                                              _expandedIndex =
                                                  _expandedIndex == i
                                                      ? null
                                                      : i),
                                        ),
                                      ),
                                      childCount: _entries.length,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ✅ Web only: 2-column grid layout for payment cards
class _WebTwoColumnList extends StatelessWidget {
  final List<PaymentEntry> entries;
  final int? expandedIndex;
  final void Function(int) onTap;

  const _WebTwoColumnList({
    required this.entries,
    required this.expandedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pair entries into rows of 2
    final rows = <List<int>>[];
    for (var i = 0; i < entries.length; i += 2) {
      rows.add([i, if (i + 1 < entries.length) i + 1]);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, rowIndex) {
          final indices = rows[rowIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PaymentCard(
                    entry: entries[indices[0]],
                    isExpanded: expandedIndex == indices[0],
                    onTap: () => onTap(indices[0]),
                  ),
                ),
                const SizedBox(width: 12),
                // ✅ If odd number of entries, fill last slot with empty space
                indices.length > 1
                    ? Expanded(
                        child: _PaymentCard(
                          entry: entries[indices[1]],
                          isExpanded: expandedIndex == indices[1],
                          onTap: () => onTap(indices[1]),
                        ),
                      )
                    : const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
        },
        childCount: rows.length,
      ),
    );
  }
}

// ── Stats Cards Row ───────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final int total;
  final int active;
  final double revenue;
  const _StatsBar(
      {required this.total, required this.active, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _StatCard(
            label: AppLocalizations.of(context)!.total,
            value: '$total',
            icon: Icons.receipt_outlined,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: AppLocalizations.of(context)!.active,
            value: '$active',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 10),
          _StatCard(
            label: AppLocalizations.of(context)!.revenue,
            value: '${revenue.toStringAsFixed(0)} DZD',
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.green, size: 18),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact + Expandable Card — completely unchanged ──────────────────────────

class _PaymentCard extends StatelessWidget {
  final PaymentEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.entry,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p       = entry.payment;
    final r       = entry.recruiter;
    final expired = p.expiresAt.isBefore(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AppColors.green.withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? AppColors.green.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isExpanded ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _Avatar(logoUrl: r?.logoUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r?.pharmacyName ?? AppLocalizations.of(context)!.unknownPharmacy,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 11,
                                color: Colors.grey.shade400),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                r != null
                                    ? '${r.city}, ${r.province}'
                                    : '—',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientgreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${p.amount.toStringAsFixed(0)} DZD',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expired
                              ? AppLocalizations.of(context)!.expired
                              : 'Until ${DateFormat('MMM yy').format(p.expiresAt)}',
                          style: TextStyle(
                              fontSize: 10,
                              color: expired
                                  ? Colors.red.shade400
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? AppColors.green
                            : Colors.grey.shade400,
                        size: 20),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _ExpandedDetail(entry: entry),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expanded Detail — unchanged ───────────────────────────────────────────────

class _ExpandedDetail extends StatelessWidget {
  final PaymentEntry entry;
  const _ExpandedDetail({required this.entry});

  @override
  Widget build(BuildContext context) {
    final p   = entry.payment;
    final r   = entry.recruiter;
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          if (r != null) ...[
            _SectionLabel(label: AppLocalizations.of(context)!.recruiter),
            const SizedBox(height: 8),
            _DetailGrid(items: [
              _GridItem(
                  icon: Icons.person_outline,
                  label: AppLocalizations.of(context)!.name,
                  value:
                      '${r.pharmacistFirstName} ${r.pharmacistLastName}'),
              _GridItem(
                  icon: Icons.map_outlined,
                  label: AppLocalizations.of(context)!.street,
                  value:
                      r.streetAddress.isEmpty ? '—' : r.streetAddress),
              _GridItem(
                  icon: Icons.verified_outlined,
                  label: AppLocalizations.of(context)!.license,
                  value: r.licenseStatus ?? 'Inactive',
                  valueColor: _licenseColor(r.licenseStatus)),
              if (r.licenseExpiresAt != null)
                _GridItem(
                    icon: Icons.event_outlined,
                    label: AppLocalizations.of(context)!.licenseExpires,
                    value: fmt.format(r.licenseExpiresAt!)),
              _GridItem(
                  icon: Icons.badge_outlined,
                  label: AppLocalizations.of(context)!.profile,
                  value: r.profileStatus),
            ]),
            const SizedBox(height: 12),
          ],
          _SectionLabel(label: AppLocalizations.of(context)!.payment),
          const SizedBox(height: 8),
          _DetailGrid(items: [
            _GridItem(
                icon: Icons.calendar_today_outlined,
                label: AppLocalizations.of(context)!.paidOn,
                value: p.paidAt != null ? fmt.format(p.paidAt!) : '—'),
            _GridItem(
                icon: Icons.timer_outlined,
                label: AppLocalizations.of(context)!.expires,
                value: fmt.format(p.expiresAt),
                valueColor: p.expiresAt.isAfter(DateTime.now())
                    ? AppColors.green
                    : Colors.red),
            _GridItem(
                icon: Icons.credit_card_outlined,
                label: AppLocalizations.of(context)!.method,
                value: _methodLabel(p.paymentMethod)),
            _GridItem(
                icon: Icons.calendar_view_month_outlined,
                label: AppLocalizations.of(context)!.year,
                value: '${p.year}'),
          ]),
          if (p.checkoutId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.tag_outlined,
                      size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context)!.checkoutId,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                  Expanded(
                    child: Text(
                      p.checkoutId,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _licenseColor(String? s) {
    switch (s) {
      case 'Active':  return AppColors.green;
      case 'Expired': return Colors.red;
      default:        return Colors.grey;
    }
  }

  String _methodLabel(String m) {
    switch (m) {
      case 'edahabia': return 'Edahabia';
      case 'cib':      return 'CIB';
      default:         return m.isEmpty ? '—' : m;
    }
  }
}

// ── unchanged widgets below ───────────────────────────────────────────────────

class _GridItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _GridItem(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});
}

class _DetailGrid extends StatelessWidget {
  final List<_GridItem> items;
  const _DetailGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = <List<_GridItem>>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
          items.sublist(i, i + 2 > items.length ? items.length : i + 2));
    }
    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: row
                      .map((item) =>
                          Expanded(child: _GridCell(item: item)))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }
}

class _GridCell extends StatelessWidget {
  final _GridItem item;
  const _GridCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 13, color: Colors.grey.shade400),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500)),
              Text(item.value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.valueColor ?? Colors.black87),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 12,
          decoration: BoxDecoration(
            gradient: AppColors.gradientgreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
                letterSpacing: 0.8)),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? logoUrl;
  const _Avatar({this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasLogo ? null : AppColors.gradientgreen,
        image: hasLogo
            ? DecorationImage(
                image: NetworkImage(logoUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: hasLogo
          ? null
          : const Icon(Icons.local_pharmacy_outlined,
              color: Colors.white, size: 20),
    );
  }
}