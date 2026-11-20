// lib/AdminPannel/PaymentConfigScreen.dart

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/PaymentConfig.dart';
import 'package:client/Server/Repo/PaymentConfigRepository.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentConfigScreen extends StatefulWidget {
  const PaymentConfigScreen({super.key});

  @override
  State<PaymentConfigScreen> createState() => _PaymentConfigScreenState();
}

class _PaymentConfigScreenState extends State<PaymentConfigScreen> {
  final _repo = PaymentConfigRepository();

  // ── Controllers ────────────────────────────────────────────────────────────
  final _testSecretKeyCtrl    = TextEditingController();
  final _cloudFunctionUrlCtrl = TextEditingController();
  final _webhookUrlCtrl       = TextEditingController();
  final _successUrlCtrl       = TextEditingController();
  final _failureUrlCtrl       = TextEditingController();
  final _annualFeeCtrl        = TextEditingController();
  final _currencyCtrl         = TextEditingController();
  final _localeCtrl           = TextEditingController();
  final _planNameCtrl         = TextEditingController();
  final _planSubtitleCtrl     = TextEditingController();
  final _planDescriptionCtrl  = TextEditingController();
  final _disclaimerCtrl       = TextEditingController();
  final _newFeatureCtrl       = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  bool         _loading   = true;
  bool         _saving    = false;
  bool         _testMode  = true;
  List<String> _features  = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _testSecretKeyCtrl.dispose();
    _cloudFunctionUrlCtrl.dispose();
    _webhookUrlCtrl.dispose();
    _successUrlCtrl.dispose();
    _failureUrlCtrl.dispose();
    _annualFeeCtrl.dispose();
    _currencyCtrl.dispose();
    _localeCtrl.dispose();
    _planNameCtrl.dispose();
    _planSubtitleCtrl.dispose();
    _planDescriptionCtrl.dispose();
    _disclaimerCtrl.dispose();
    _newFeatureCtrl.dispose();
    super.dispose();
  }

  // ── Load ───────────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() => _loading = true);
    final cfg = await _repo.get();
    _populate(cfg);
    setState(() => _loading = false);
  }

  void _populate(PaymentConfig cfg) {
    _testMode = cfg.testMode;
    _testSecretKeyCtrl.text    = cfg.testSecretKey;
    _cloudFunctionUrlCtrl.text = cfg.cloudFunctionUrl;
    _webhookUrlCtrl.text       = cfg.webhookUrl;
    _successUrlCtrl.text       = cfg.successUrl;
    _failureUrlCtrl.text       = cfg.failureUrl;
    _annualFeeCtrl.text        = cfg.annualFee.toStringAsFixed(0);
    _currencyCtrl.text         = cfg.currency;
    _localeCtrl.text           = cfg.locale;
    _planNameCtrl.text         = cfg.planName;
    _planSubtitleCtrl.text     = cfg.planSubtitle;
    _planDescriptionCtrl.text  = cfg.planDescription;
    _disclaimerCtrl.text       = cfg.disclaimer;
    _features                  = List.from(cfg.features);
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    final fee = double.tryParse(_annualFeeCtrl.text.trim());
    if (fee == null) {
      _showError(AppLocalizations.of(context)!.annualFeeError);
      return;
    }

    setState(() => _saving = true);

    final cfg = PaymentConfig(
      testMode:         _testMode,
      testSecretKey:    _testSecretKeyCtrl.text.trim(),
      cloudFunctionUrl: _cloudFunctionUrlCtrl.text.trim(),
      webhookUrl:       _webhookUrlCtrl.text.trim(),
      successUrl:       _successUrlCtrl.text.trim(),
      failureUrl:       _failureUrlCtrl.text.trim(),
      annualFee:        fee,
      currency:         _currencyCtrl.text.trim().toLowerCase(),
      locale:           _localeCtrl.text.trim().toLowerCase(),
      planName:         _planNameCtrl.text.trim(),
      planSubtitle:     _planSubtitleCtrl.text.trim(),
      planDescription:  _planDescriptionCtrl.text.trim(),
      features:         List.from(_features),
      disclaimer:       _disclaimerCtrl.text.trim(),
    );

    try {
      await _repo.set(cfg);
      if (mounted) _showSuccess(AppLocalizations.of(context)!.saveSuccess);
    } catch (e) {
      if (mounted) _showError(AppLocalizations.of(context)!.saveError( e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Feature management ─────────────────────────────────────────────────────
  void _addFeature() {
    final text = _newFeatureCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _features.add(text));
    _newFeatureCtrl.clear();
  }

  void _removeFeature(int index) {
    setState(() => _features.removeAt(index));
  }

  void _reorderFeature(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _features.removeAt(oldIndex);
      _features.insert(newIndex, item);
    });
  }

  // ── Snackbars ──────────────────────────────────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title:  Text(
          AppLocalizations.of(context)!.paymentConfigTitle,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _saving
                  ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : _GradientButton(
                label: AppLocalizations.of(context)!.save,
                icon: Icons.save_rounded,
                onPressed: _save,
                compact: true,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        color: AppColors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Environment ──────────────────────────────────
              _SectionCard(
                icon: Icons.science_outlined,
                iconColor: Colors.orange,
                title: AppLocalizations.of(context)!.environment,
                subtitle: AppLocalizations.of(context)!.environmentSubtitle,
                child: _EnvironmentToggle(
                  testMode: _testMode,
                  onChanged: (val) => setState(() => _testMode = val),
                ),
              ),

              const SizedBox(height: 16),

              // ── API Credentials ──────────────────────────────
              _SectionCard(
                icon: Icons.key_rounded,
                iconColor: Colors.purple.shade400,
                title: AppLocalizations.of(context)!.apiCredentials,
                subtitle: AppLocalizations.of(context)!.apiCredentialsSubtitle,
                child: Column(
                  children: [
                    _ConfigField(
                      label: AppLocalizations.of(context)!.testSecretKey,

                      controller: _testSecretKeyCtrl,
                      hint: 'test_sk_...',
                      icon: Icons.vpn_key_outlined,
                      obscure: true,
                      monospace: true,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.cloudFunctionUrl,
                      controller: _cloudFunctionUrlCtrl,
                      hint: 'https://...',
                      icon: Icons.cloud_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.webhookUrl,
                      controller: _webhookUrlCtrl,
                      hint: 'https://...',
                      icon: Icons.webhook_outlined,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Redirect URLs ────────────────────────────────
              _SectionCard(
                icon: Icons.link_rounded,
                iconColor: Colors.blue.shade400,
                title: AppLocalizations.of(context)!.redirectUrls,
                subtitle: AppLocalizations.of(context)!.redirectUrlsSubtitle,
                child: Column(
                  children: [
                    _ConfigField(
                      label: AppLocalizations.of(context)!.successUrl,
                      controller: _successUrlCtrl,
                      hint: 'https://officina-payment.web.app',
                      icon: Icons.check_circle_outline,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.failureUrl,
                      controller: _failureUrlCtrl,
                      hint: 'https://officina-payment.web.app/failure.html',
                      icon: Icons.cancel_outlined,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Pricing ──────────────────────────────────────
              _SectionCard(
                icon: Icons.payments_outlined,
                iconColor: Colors.green.shade600,
                title: AppLocalizations.of(context)!.pricing,
                subtitle: AppLocalizations.of(context)!.pricingSubtitle,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ConfigField(
                        label: AppLocalizations.of(context)!.annualFee,
                        controller: _annualFeeCtrl,
                        hint: '12000',
                        icon: Icons.attach_money_rounded,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _ConfigField(
                        label: 'Currency',
                        controller: _currencyCtrl,
                        hint: 'dzd',
                        icon: Icons.currency_exchange_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: _ConfigField(
                        label: 'Locale',
                        controller: _localeCtrl,
                        hint: 'en',
                        icon: Icons.language_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Plan UI Copy ─────────────────────────────────
              _SectionCard(
                icon: Icons.text_fields_rounded,
                iconColor: Colors.teal.shade400,
                title: AppLocalizations.of(context)!.planCopy,
                subtitle: AppLocalizations.of(context)!.planCopySubtitle,
                child: Column(
                  children: [
                    _ConfigField(
                      label: AppLocalizations.of(context)!.planName,
                      controller: _planNameCtrl,
                      hint: 'Annual Pharmacy Recruiter Plan',
                      icon: Icons.workspace_premium_rounded,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.planSubtitle,
                      controller: _planSubtitleCtrl,
                      hint: 'Post pharmacy job listings for 12 months',
                      icon: Icons.subtitles_outlined,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.planDescription,
                      controller: _planDescriptionCtrl,
                      hint: 'Full access to pharmacy hiring tools...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _ConfigField(
                      label: AppLocalizations.of(context)!.disclaimer,
                      controller: _disclaimerCtrl,
                      hint:'Annual pharmacy recruitment service billed once per year...',
                      icon: Icons.info_outline_rounded,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Features List ────────────────────────────────
              _SectionCard(
                icon: Icons.checklist_rounded,
                iconColor: AppColors.green,
                title: AppLocalizations.of(context)!.planFeatures,
                subtitle: AppLocalizations.of(context)!.planFeaturesSubtitle,
                child: Column(
                  children: [
                    // Add new feature
                    Row(
                      children: [
                        Expanded(
                          child: _ConfigField(
                            label: AppLocalizations.of(context)!.newFeature,
                            controller: _newFeatureCtrl,
                            hint:
                            'e.g. Post pharmacy job listings...',
                            icon: Icons.add_circle_outline,
                            onSubmitted: (_) => _addFeature(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CircleIconButton(
                          icon: Icons.add_rounded,
                          color: AppColors.green,
                          onPressed: _addFeature,
                        ),
                      ],
                    ),

                    if (_features.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Reorderable list
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _features.length,
                        onReorder: _reorderFeature,
                        proxyDecorator: (child, index, animation) =>
                            Material(
                              color: Colors.transparent,
                              child: child,
                            ),
                        itemBuilder: (_, i) {
                          return _FeatureTile(
                            key: ValueKey('feature_$i'),
                            text: _features[i],
                            index: i,
                            onDelete: () => _removeFeature(i),
                            onEdit: (newText) {
                              setState(
                                      () => _features[i] = newText);
                            },
                          );
                        },
                      ),
                    ],

                    if (_features.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.noFeatures,
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Save button (bottom) ─────────────────────────
              _saving
                  ? const Center(
                  child: CircularProgressIndicator())
                  : _GradientButton(
                label: AppLocalizations.of(context)!.saveConfiguration,
                icon: Icons.save_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Environment Toggle ───────────────────────────────────────────────────────

class _EnvironmentToggle extends StatelessWidget {
  final bool testMode;
  final ValueChanged<bool> onChanged;

  const _EnvironmentToggle({
    required this.testMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _EnvChip(
            label: AppLocalizations.of(context)!.testMode,
            sublabel: AppLocalizations.of(context)!.testModeSubtitle,
            icon: Icons.science_outlined,
            color: Colors.orange,
            selected: testMode,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _EnvChip(
            label: AppLocalizations.of(context)!.production,
            sublabel: AppLocalizations.of(context)!.productionSubtitle,
            icon: Icons.rocket_launch_outlined,
            color: AppColors.green,
            selected: !testMode,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _EnvChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _EnvChip({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected ? color : Colors.grey.shade400),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? color : Colors.grey.shade500)),
                  Text(sublabel,
                      style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? color.withOpacity(0.7)
                              : Colors.grey.shade400)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   title;
  final String   subtitle;
  final Widget   child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 14),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Config Field ─────────────────────────────────────────────────────────────

class _ConfigField extends StatefulWidget {
  final String                    label;
  final TextEditingController     controller;
  final String                    hint;
  final IconData                  icon;
  final bool                      obscure;
  final bool                      monospace;
  final int                       maxLines;
  final TextInputType?            keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>?     onSubmitted;

  const _ConfigField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure        = false,
    this.monospace      = false,
    this.maxLines       = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
  });

  @override
  State<_ConfigField> createState() => _ConfigFieldState();
}

class _ConfigFieldState extends State<_ConfigField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscure && _obscured,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(
              fontSize: 13,
              fontFamily: widget.monospace ? 'monospace' : null,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                  color: Colors.grey.shade400, fontSize: 12),
              prefixIcon: Icon(widget.icon,
                  size: 17, color: Colors.grey.shade400),
              suffixIcon: widget.obscure
                  ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 17,
                  color: Colors.grey.shade400,
                ),
                onPressed: () =>
                    setState(() => _obscured = !_obscured),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Feature Tile ─────────────────────────────────────────────────────────────

class _FeatureTile extends StatefulWidget {
  final String         text;
  final int            index;
  final VoidCallback   onDelete;
  final ValueChanged<String> onEdit;

  const _FeatureTile({
    super.key,
    required this.text,
    required this.index,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isNotEmpty) widget.onEdit(text);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.green.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Drag handle
          Icon(Icons.drag_handle_rounded,
              size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 10),

          // Number badge
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text or edit field
          Expanded(
            child: _editing
                ? TextField(
              controller: _ctrl,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
                : Text(widget.text,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87)),
          ),

          // Edit / confirm
          _editing
              ? IconButton(
            icon: Icon(Icons.check_rounded,
                size: 16, color: AppColors.green),
            onPressed: _submit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
              : IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 16, color: Colors.grey.shade500),
            onPressed: () => setState(() => _editing = true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 4),

          // Delete
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 16, color: Colors.red.shade300),
            onPressed: widget.onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─── Circle Icon Button ───────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final VoidCallback onPressed;
  final bool         compact;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? null : double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.gradientgreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor:     Colors.transparent,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}