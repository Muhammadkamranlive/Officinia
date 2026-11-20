
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/ExperienceLevelModel.dart';
import 'package:client/Server/Repo/ExperienceLevelRepository.dart';

import '../l10n/app_localizations.dart';

class ManageExperienceLevelsScreen extends StatefulWidget {
  const ManageExperienceLevelsScreen({super.key});

  @override
  State<ManageExperienceLevelsScreen> createState() =>
      _ManageExperienceLevelsScreenState();
}

class _ManageExperienceLevelsScreenState
    extends State<ManageExperienceLevelsScreen> {
  final _repo = ExperienceLevelRepository();
  List<ExperienceLevelModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _repo.getAllExperienceLevels();
    setState(() {
      _items = list..sort((a, b) => a.order.compareTo(b.order));
      _loading = false;
    });
  }

  void _openForm({ExperienceLevelModel? existing}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExperienceFormSheet(
        existing: existing,
        order: _items.length,
        repo: _repo,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleActive(ExperienceLevelModel item) async {
    item.isActive
        ? await _repo.deactivate(item.docId!)
        : await _repo.activate(item.docId!);
    _load();
  }

  Future<void> _delete(ExperienceLevelModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:  Text(AppLocalizations.of(context)!.deleteOptionConfirm( item.en)),
        content: Text(AppLocalizations.of(context)!.deleteOptionConfirm(item.en)),
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
      await _repo.delete(item.docId!);
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
        title:  Text(
          AppLocalizations.of(context)!.experienceLevelsTitle,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _items.length.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.noExperienceLevels,
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.addNewHint,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.green,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return _ExperienceTile(
                        item: item,
                        onEdit: () => _openForm(existing: item),
                        onToggle: () => _toggleActive(item),
                        onDelete: () => _delete(item),
                      );
                    },
                  ),
                ),
      floatingActionButton: _GradientFAB(onPressed: () => _openForm()),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _ExperienceTile extends StatelessWidget {
  final ExperienceLevelModel item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ExperienceTile({
    required this.item,
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
              offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading circle ──
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: item.isActive ? AppColors.gradientgreen : null,
              color: item.isActive ? null : Colors.grey.shade200,
            ),
            child: Center(
              child: Text(
                '${item.order + 1}',
                style: TextStyle(
                  color: item.isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Title + lang chips (flexible) ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.en,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: item.isActive ? Colors.black87 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _LangChip(label: 'FR', text: item.fr),
                    _LangChip(label: 'AR', text: item.ar),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Actions (unconstrained, stacked vertically) ──
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Toggle chip
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? AppColors.green.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isActive
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 13,
                        color: item.isActive ? AppColors.green : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        item.isActive ? 'Active' : 'Hidden',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              item.isActive ? AppColors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Edit + Delete icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: Colors.grey.shade500,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red.shade300,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Form Sheet ───────────────────────────────────────────────────────────────

class _ExperienceFormSheet extends StatefulWidget {
  final ExperienceLevelModel? existing;
  final int order;
  final ExperienceLevelRepository repo;

  const _ExperienceFormSheet({
    required this.existing,
    required this.order,
    required this.repo,
  });

  @override
  State<_ExperienceFormSheet> createState() => _ExperienceFormSheetState();
}

class _ExperienceFormSheetState extends State<_ExperienceFormSheet> {
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

    final level = ExperienceLevelModel(
      docId: widget.existing?.docId,
      en: _enCtrl.text.trim(),
      fr: _frCtrl.text.trim(),
      ar: _arCtrl.text.trim(),
      order: widget.existing?.order ?? widget.order,
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      await widget.repo.update(level.docId!, level);
    } else {
      await widget.repo.add(level);
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
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Cap sheet height so it scrolls on small screens
      constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
      child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(2)),
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
                  child: const Icon(Icons.trending_up_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEdit ? AppLocalizations.of(context)!.editExperienceLevel : AppLocalizations.of(context)!.addExperienceLevel,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        AppLocalizations.of(context)!.fillLanguages,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: _saving
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientgreen,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.green.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _isEdit ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.add,
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
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  final String label;
  final String text;

  const _LangChip({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green)),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

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
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Directionality(
              textDirection: textDirection,
              child: TextField(
                controller: controller,
                textDirection: textDirection,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.nameInLanguage(lang),
                    border: InputBorder.none),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
              offset: const Offset(0, 4)),
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