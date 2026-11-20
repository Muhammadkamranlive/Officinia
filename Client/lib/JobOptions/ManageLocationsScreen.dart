import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Repo/LocationRepository.dart';

import '../l10n/app_localizations.dart';

// ─── Level 1: Provinces ───────────────────────────────────────────────────────

class ManageLocationsScreen extends StatefulWidget {
  const ManageLocationsScreen({super.key});

  @override
  State<ManageLocationsScreen> createState() => _ManageLocationsScreenState();
}

class _ManageLocationsScreenState extends State<ManageLocationsScreen> {
  final _repo = LocationRepository();
  List<ProvinceModel> _provinces = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAllProvinces();
    setState(() {
      _provinces = list..sort((a, b) => a.order.compareTo(b.order));
      _loading = false;
    });
  }

  void _openForm({ProvinceModel? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProvinceFormSheet(
        existing: existing,
        order: _provinces.length,
        repo: _repo,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleActive(ProvinceModel p) async {
    p.isActive
        ? await _repo.deactivateProvince(p.docId!)
        : await _repo.activateProvince(p.docId!);
    _load();
  }

  Future<void> _delete(ProvinceModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(AppLocalizations.of(context)!.deleteProvinceTitle),
        content: Text(AppLocalizations.of(context)!.deleteProvinceMessage( p.en)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child:  Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child:
                   Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteProvince(p.docId!);
      _load();
    }
  }

  void _openCities(ProvinceModel province) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CitiesScreen(province: province, repo: _repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title:  Text(AppLocalizations.of(context)!.titleProvincesCities,
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _InfoBadge(label: '${_provinces.length}'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _provinces.isEmpty
              ? _EmptyState(
                  icon: Icons.location_city_outlined,
                  message: AppLocalizations.of(context)!.noProvinces,
                  sub: AppLocalizations.of(context)!.addProvinceHint,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.green,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _provinces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = _provinces[i];
                      return _ProvinceTile(
                        province: p,
                        onTap: () => _openCities(p),
                        onEdit: () => _openForm(existing: p),
                        onToggle: () => _toggleActive(p),
                        onDelete: () => _delete(p),
                      );
                    },
                  ),
                ),
      floatingActionButton: _GradientFAB(onPressed: () => _openForm()),
    );
  }
}

// ─── Province Tile ────────────────────────────────────────────────────────────

class _ProvinceTile extends StatelessWidget {
  final ProvinceModel province;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProvinceTile({
    required this.province,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Leading circle ──
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    province.isActive ? AppColors.gradientgreen : null,
                color: province.isActive ? null : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  '${province.order + 1}',
                  style: TextStyle(
                    color: province.isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── Title + chips ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Province name + Cities button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          province.en,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: province.isActive
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.cities,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded,
                                size: 13, color: AppColors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // ✅ Wrap prevents overflow on small screens
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _LangChip(label: 'FR', text: province.fr),
                      _LangChip(label: 'AR', text: province.ar),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Actions ──
            _ActionColumn(
              isActive: province.isActive,
              onEdit: onEdit,
              onToggle: onToggle,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Level 2: Cities ─────────────────────────────────────────────────────────

class _CitiesScreen extends StatefulWidget {
  final ProvinceModel province;
  final LocationRepository repo;

  const _CitiesScreen({required this.province, required this.repo});

  @override
  State<_CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<_CitiesScreen> {
  List<CityModel> _cities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list =
        await widget.repo.getAllCities(widget.province.docId!);
    setState(() {
      _cities = list..sort((a, b) => a.order.compareTo(b.order));
      _loading = false;
    });
  }

  void _openForm({CityModel? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityFormSheet(
        existing: existing,
        provinceId: widget.province.docId!,
        order: _cities.length,
        repo: widget.repo,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleActive(CityModel c) async {
    c.isActive
        ? await widget.repo
            .deactivateCity(widget.province.docId!, c.docId!)
        : await widget.repo
            .activateCity(widget.province.docId!, c.docId!);
    _load();
  }

  Future<void> _delete(CityModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(AppLocalizations.of(context)!.deleteCityTitle),
        content: Text(AppLocalizations.of(context)!.deleteCityMessage(c.en)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child:  Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child:  Text(AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await widget.repo.deleteCity(widget.province.docId!, c.docId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.province.en,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              AppLocalizations.of(context)!.cities,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _InfoBadge(label: '${_cities.length} ' + AppLocalizations.of(context)!.cities),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _cities.isEmpty
              ? _EmptyState(
                  icon: Icons.location_on_outlined,
                  message: AppLocalizations.of(context)!.noCities,
                  sub: AppLocalizations.of(context)!.addCityHint(widget.province.en),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.green,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _cities.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = _cities[i];
                      return _CityTile(
                        city: c,
                        onEdit: () => _openForm(existing: c),
                        onToggle: () => _toggleActive(c),
                        onDelete: () => _delete(c),
                      );
                    },
                  ),
                ),
      floatingActionButton:
          _GradientFAB(onPressed: () => _openForm()),
    );
  }
}

// ─── City Tile ────────────────────────────────────────────────────────────────

class _CityTile extends StatelessWidget {
  final CityModel city;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _CityTile({
    required this.city,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading circle ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: city.isActive ? AppColors.gradientgreen : null,
              color: city.isActive ? null : Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                '${city.order + 1}',
                style: TextStyle(
                  color: city.isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Title + chips ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  city.en,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: city.isActive ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),

                // ✅ Wrap prevents overflow on small screens
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _LangChip(label: 'FR', text: city.fr),
                    _LangChip(label: 'AR', text: city.ar),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Actions ──
          _ActionColumn(
            isActive: city.isActive,
            onEdit: onEdit,
            onToggle: onToggle,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Province Form Sheet ──────────────────────────────────────────────────────

class _ProvinceFormSheet extends StatefulWidget {
  final ProvinceModel? existing;
  final int order;
  final LocationRepository repo;

  const _ProvinceFormSheet({
    required this.existing,
    required this.order,
    required this.repo,
  });

  @override
  State<_ProvinceFormSheet> createState() => _ProvinceFormSheetState();
}

class _ProvinceFormSheetState extends State<_ProvinceFormSheet> {
  final _enCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _arCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _enCtrl.text = widget.existing!.en;
      _frCtrl.text = widget.existing!.fr;
      _arCtrl.text = widget.existing!.ar;
    }
  }

  @override
  void dispose() {
    _enCtrl.dispose();
    _frCtrl.dispose();
    _arCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_enCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.englishRequired);
      return false;
    }
    if (_frCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.frenchRequired);
      return false;
    }
    if (_arCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.arabicRequired);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);
    final province = ProvinceModel(
      docId: widget.existing?.docId,
      en: _enCtrl.text.trim(),
      fr: _frCtrl.text.trim(),
      ar: _arCtrl.text.trim(),
      order: widget.existing?.order ?? widget.order,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    if (_isEdit) {
      await widget.repo.updateProvince(province);
    } else {
      await widget.repo.addProvince(province);
    }
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return _FormSheetScaffold(
      isEdit: _isEdit,
      icon: Icons.location_city_outlined,
      title: _isEdit ? AppLocalizations.of(context)!.editProvince : AppLocalizations.of(context)!.addProvince,
      saving: _saving,
      onSave: _save,
      children: [
        _LangField(
            flag: '🇬🇧',
            lang: AppLocalizations.of(context)!.english,
            controller: _enCtrl,
            textDirection: TextDirection.ltr),
        const SizedBox(height: 14),
        _LangField(
            flag: '🇫🇷',
            lang: AppLocalizations.of(context)!.french,
            controller: _frCtrl,
            textDirection: TextDirection.ltr),
        const SizedBox(height: 14),
        _LangField(
            flag: '🇩🇿',
            lang: AppLocalizations.of(context)!.arabic,
            controller: _arCtrl,
            textDirection: TextDirection.rtl),
      ],
    );
  }
}

// ─── City Form Sheet ──────────────────────────────────────────────────────────

class _CityFormSheet extends StatefulWidget {
  final CityModel? existing;
  final String provinceId;
  final int order;
  final LocationRepository repo;

  const _CityFormSheet({
    required this.existing,
    required this.provinceId,
    required this.order,
    required this.repo,
  });

  @override
  State<_CityFormSheet> createState() => _CityFormSheetState();
}

class _CityFormSheetState extends State<_CityFormSheet> {
  final _enCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _arCtrl = TextEditingController();
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _enCtrl.text = widget.existing!.en;
      _frCtrl.text = widget.existing!.fr;
      _arCtrl.text = widget.existing!.ar;
    }
  }

  @override
  void dispose() {
    _enCtrl.dispose();
    _frCtrl.dispose();
    _arCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_enCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.englishRequired);
      return false;
    }
    if (_frCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.frenchRequired);
      return false;
    }
    if (_arCtrl.text.trim().isEmpty) {
      _err(AppLocalizations.of(context)!.arabicRequired);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);
    final city = CityModel(
      docId: widget.existing?.docId,
      provinceId: widget.provinceId,
      en: _enCtrl.text.trim(),
      fr: _frCtrl.text.trim(),
      ar: _arCtrl.text.trim(),
      order: widget.existing?.order ?? widget.order,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    if (_isEdit) {
      await widget.repo.updateCity(city);
    } else {
      await widget.repo.addCity(city);
    }
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  void _err(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating),
      );

  @override
  Widget build(BuildContext context) {
    return _FormSheetScaffold(
      isEdit: _isEdit,
      icon: Icons.location_on_outlined,
      title: _isEdit ? AppLocalizations.of(context)!.editCity : AppLocalizations.of(context)!.addCity,
      saving: _saving,
      onSave: _save,
      children: [
        _LangField(
            flag: '🇬🇧',
            lang: AppLocalizations.of(context)!.english,
            controller: _enCtrl,
            textDirection: TextDirection.ltr),
        const SizedBox(height: 14),
        _LangField(
            flag: '🇫🇷',
            lang: AppLocalizations.of(context)!.french,
            controller: _frCtrl,
            textDirection: TextDirection.ltr),
        const SizedBox(height: 14),
        _LangField(
            flag: '🇩🇿',
            lang: AppLocalizations.of(context)!.arabic,
            controller: _arCtrl,
            textDirection: TextDirection.rtl),
      ],
    );
  }
}

// ─── Shared: Form Sheet Scaffold ──────────────────────────────────────────────

class _FormSheetScaffold extends StatelessWidget {
  final bool isEdit;
  final IconData icon;
  final String title;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> children;

  const _FormSheetScaffold({
    required this.isEdit,
    required this.icon,
    required this.title,
    required this.saving,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientgreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                    Text(AppLocalizations.of(context)!.fillLanguages,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 28),
          // Save button
          SizedBox(
            width: double.infinity,
            child: saving
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientgreen,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        isEdit ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.add,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared: Action Column ────────────────────────────────────────────────────

class _ActionColumn extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ActionColumn({
    required this.isActive,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Toggle chip ──
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.green.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 12,
                  color: isActive ? AppColors.green : Colors.grey,
                ),
                const SizedBox(width: 3),
                Text(
                  isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.hidden,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // ── Edit + Delete ──
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SmallIconButton(
              icon: Icons.edit_outlined,
              color: AppColors.green,
              onTap: onEdit,
            ),
            const SizedBox(width: 2),
            _SmallIconButton(
              icon: Icons.delete_outline,
              color: Colors.red,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Shared: Small Icon Button ────────────────────────────────────────────────

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ─── Shared: Lang Chip ────────────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  final String label;
  final String text;

  const _LangChip({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    // ✅ ConstrainedBox on the whole chip prevents overflow
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 4),
            // ✅ Flexible lets text shrink and ellipsis inside the chip
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared: Lang Field ───────────────────────────────────────────────────────

class _LangField extends StatelessWidget {
  final String flag;
  final String lang;
  final TextEditingController controller;
  final TextDirection textDirection;

  const _LangField({
    required this.flag,
    required this.lang,
    required this.controller,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(flag, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(lang,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
        ]),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.gradientgreen,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Directionality(
              textDirection: textDirection,
              child: TextField(
                controller: controller,
                textDirection: textDirection,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.nameInLanguage(lang),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared: Gradient FAB ─────────────────────────────────────────────────────

class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _GradientFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.gradientgreen,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── Shared: Info Badge ───────────────────────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final String label;
  const _InfoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.green,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Shared: Empty State ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;

  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(sub,
              style:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}