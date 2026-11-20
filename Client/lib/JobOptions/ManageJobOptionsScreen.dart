
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';

import '../l10n/app_localizations.dart';

class ManageJobOptionsScreen extends StatefulWidget {
  const ManageJobOptionsScreen({super.key});

  @override
  State<ManageJobOptionsScreen> createState() => _ManageJobOptionsScreenState();
}

class _ManageJobOptionsScreenState extends State<ManageJobOptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _repo = JobOptionRepository();

  List<JobOption> _jobTitles = [];
  List<JobOption> _skills = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _repo.getAllOptions();
    setState(() {
      _jobTitles = all.where((e) => e.type == JobOptionType.jobTitle).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _skills = all.where((e) => e.type == JobOptionType.skill).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _loading = false;
    });
  }

  void _openForm({JobOption? existing, required JobOptionType type}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JobOptionFormSheet(
        existing: existing,
        type: type,
        order: type == JobOptionType.jobTitle
            ? _jobTitles.length
            : _skills.length,
        repo: _repo,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleActive(JobOption option) async {
    if (option.isActive) {
      await _repo.deactivate(option.docId!);
    } else {
      await _repo.activate(option.docId!);
    }
    _load();
  }

  Future<void> _delete(JobOption option) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteOption),
        content: Text(l10n.deleteOptionConfirm(option.en)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child:  Text(l10n.cancel, style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child:  Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.delete(option.docId!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        title:  Text(l10n.manageOptions,
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.green,
          indicatorWeight: 3,
          tabs:  [
            Tab(text: l10n.jobTitles),
            Tab(text: l10n.skills),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _OptionList(
                  items: _jobTitles,
                  onEdit: (o) =>
                      _openForm(existing: o, type: JobOptionType.jobTitle),
                  onToggle: _toggleActive,
                  onDelete: _delete,
                ),
                _OptionList(
                  items: _skills,
                  onEdit: (o) =>
                      _openForm(existing: o, type: JobOptionType.skill),
                  onToggle: _toggleActive,
                  onDelete: _delete,
                ),
              ],
            ),
      floatingActionButton: _GradientFAB(
        onPressed: () => _openForm(
          type: _tabController.index == 0
              ? JobOptionType.jobTitle
              : JobOptionType.skill,
        ),
      ),
    );
  }
}

// ─── Option List ─────────────────────────────────────────────────────────────

class _OptionList extends StatelessWidget {
  final List<JobOption> items;
  final void Function(JobOption) onEdit;
  final void Function(JobOption) onToggle;
  final void Function(JobOption) onDelete;

  const _OptionList({
    required this.items,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(l10n.noOptions,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = items[i];
        return _OptionTile(
          option: item,
          onEdit: () => onEdit(item),
          onToggle: () => onToggle(item),
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}

// ─── Option Tile ─────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final JobOption option;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _OptionTile({
    required this.option,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Order circle ──────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: option.isActive ? AppColors.gradientgreen : null,
                color: option.isActive ? null : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  '${option.order + 1}',
                  style: TextStyle(
                    color: option.isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // ── Title + lang chips ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.en,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: option.isActive ? Colors.black87 : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  // ✅ Wrap prevents overflow when chips are too wide
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _LangChip(label: 'FR', text: option.fr),
                      _LangChip(label: 'AR', text: option.ar),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Actions column ────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Active / Hidden badge
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: option.isActive
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                    ),
                    child: Text(
                      option.isActive ? 'Active' : 'Hidden',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: option.isActive
                            ? Colors.green.shade700
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small Icon Button ────────────────────────────────────────────────────────

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

// ─── Language Chip ────────────────────────────────────────────────────────────

class _LangChip extends StatelessWidget {
  final String label;
  final String text;
  const _LangChip({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    // ✅ Constrain chip width so it never overflows its parent
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
              ),
              TextSpan(
                // ✅ Let ConstrainedBox + RichText overflow handle clipping
                // instead of manually slicing the string
                text: text,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add / Edit Form Bottom Sheet ────────────────────────────────────────────

class _JobOptionFormSheet extends StatefulWidget {
  final JobOption? existing;
  final JobOptionType type;
  final int order;
  final JobOptionRepository repo;

  const _JobOptionFormSheet({
    this.existing,
    required this.type,
    required this.order,
    required this.repo,
  });

  @override
  State<_JobOptionFormSheet> createState() => _JobOptionFormSheetState();
}

class _JobOptionFormSheetState extends State<_JobOptionFormSheet> {
  final _enCtrl = TextEditingController();
  final _frCtrl = TextEditingController();
  final _arCtrl = TextEditingController();
  bool _saving = false;

  bool get isEdit => widget.existing != null;
  late final l10n = AppLocalizations.of(context)!;
  @override
  void initState() {
    super.initState();
    if (isEdit) {
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
      _error(l10n.englishRequired);
      return false;
    }
    if (_frCtrl.text.trim().isEmpty) {
      _error(l10n.frenchRequired);
      return false;
    }
    if (_arCtrl.text.trim().isEmpty) {
      _error(l10n.arabicRequired);
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);

    final option = JobOption(
      docId: widget.existing?.docId,
      type: widget.type,
      order: widget.existing?.order ?? widget.order,
      en: _enCtrl.text.trim(),
      fr: _frCtrl.text.trim(),
      ar: _arCtrl.text.trim(),
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (isEdit) {
      await widget.repo.update(option.docId!, option);
    } else {
      await widget.repo.add(option);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final typeName =
        widget.type == JobOptionType.jobTitle ? 'Job Title' : 'Skill';
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
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

          Text(
            '${isEdit ? l10n.edit_job : l10n.add} $typeName',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.fillAllLanguages,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),

          _LangField(
            flag: '🇬🇧',
            lang: l10n.english,
            controller: _enCtrl,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 14),

          _LangField(
            flag: '🇫🇷',
            lang: l10n.french,
            controller: _frCtrl,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 14),

          _LangField(
            flag: '🇩🇿',
            lang: l10n.arabic,
            controller: _arCtrl,
            textDirection: TextDirection.rtl,
          ),
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
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isEdit ? l10n.update : l10n.add,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Language Input Field ─────────────────────────────────────────────────────

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
        Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              lang,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Directionality(
              textDirection: textDirection,
              child: TextField(
                controller: controller,
                textDirection: textDirection,
                decoration: InputDecoration(
                  hintText: 'Label in $lang',
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

// ─── Gradient FAB ─────────────────────────────────────────────────────────────

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