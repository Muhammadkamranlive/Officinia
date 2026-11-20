// lib/Screens/Admin/ManageAppOptionsScreen.dart

import 'package:client/Server/Model/AppOptionType.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';

import 'package:client/Server/Repo/AppOptionRepository.dart';

class ManageAppOptionsScreen extends StatefulWidget {
  const ManageAppOptionsScreen({super.key});

  @override
  State<ManageAppOptionsScreen> createState() =>
      _ManageAppOptionsScreenState();
}

class _ManageAppOptionsScreenState extends State<ManageAppOptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _repo = AppOptionRepository();

  List<AppOption> _provinces = [];
  List<AppOption> _jobTypes = [];
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
      _provinces = all
          .where((e) => e.type == AppOptionType.province)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _jobTypes = all
          .where((e) => e.type == AppOptionType.jobType)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _loading = false;
    });
  }

  void _openForm({AppOption? existing, required AppOptionType type}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppOptionFormSheet(
        existing: existing,
        type: type,
        order: type == AppOptionType.province
            ? _provinces.length
            : _jobTypes.length,
        repo: _repo,
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleActive(AppOption option) async {
    option.isActive
        ? await _repo.deactivate(option.docId!)
        : await _repo.activate(option.docId!);
    _load();
  }

  Future<void> _delete(AppOption option) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Option'),
        content: Text('Delete "${option.en}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Provinces & Job Types',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.green,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Provinces'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_outline, size: 16),
                  SizedBox(width: 6),
                  Text('Job Types'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _OptionList(
                  items: _provinces,
                  type: AppOptionType.province,
                  onEdit: (o) =>
                      _openForm(existing: o, type: AppOptionType.province),
                  onToggle: _toggleActive,
                  onDelete: _delete,
                ),
                _OptionList(
                  items: _jobTypes,
                  type: AppOptionType.jobType,
                  onEdit: (o) =>
                      _openForm(existing: o, type: AppOptionType.jobType),
                  onToggle: _toggleActive,
                  onDelete: _delete,
                ),
              ],
            ),
      floatingActionButton: _GradientFAB(
        onPressed: () => _openForm(
          type: _tabController.index == 0
              ? AppOptionType.province
              : AppOptionType.jobType,
        ),
      ),
    );
  }
}

// ─── Option List ──────────────────────────────────────────────────────────────

class _OptionList extends StatelessWidget {
  final List<AppOption> items;
  final AppOptionType type;
  final void Function(AppOption) onEdit;
  final void Function(AppOption) onToggle;
  final void Function(AppOption) onDelete;

  const _OptionList({
    required this.items,
    required this.type,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == AppOptionType.province
                  ? Icons.location_city_outlined
                  : Icons.work_off_outlined,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No ${type.displayName.toLowerCase()}s yet',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add one',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
            ),
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

// ─── Option Tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final AppOption option;
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
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
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
              ),
            ),
          ),
        ),
        title: Text(
          option.en,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: option.isActive ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _LangChip(label: 'FR', text: option.fr),
              const SizedBox(width: 6),
              _LangChip(label: 'AR', text: option.ar),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active / Hidden toggle
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: option.isActive
                      ? AppColors.green.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.isActive
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 14,
                      color:
                          option.isActive ? AppColors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      option.isActive ? 'Active' : 'Hidden',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: option.isActive
                            ? AppColors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Edit
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              color: Colors.grey.shade500,
              onPressed: onEdit,
            ),

            // Delete
            IconButton(
              icon:
                  const Icon(Icons.delete_outline, size: 18),
              color: Colors.red.shade300,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lang Chip ────────────────────────────────────────────────────────────────

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
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
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

// ─── Form Bottom Sheet ────────────────────────────────────────────────────────

class _AppOptionFormSheet extends StatefulWidget {
  final AppOption? existing;
  final AppOptionType type;
  final int order;
  final AppOptionRepository repo;

  const _AppOptionFormSheet({
    required this.existing,
    required this.type,
    required this.order,
    required this.repo,
  });

  @override
  State<_AppOptionFormSheet> createState() => _AppOptionFormSheetState();
}

class _AppOptionFormSheetState extends State<_AppOptionFormSheet> {
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
      _showError('English label is required');
      return false;
    }
    if (_frCtrl.text.trim().isEmpty) {
      _showError('French label is required');
      return false;
    }
    if (_arCtrl.text.trim().isEmpty) {
      _showError('Arabic label is required');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _saving = true);

    final option = AppOption(
      docId: widget.existing?.docId,
      type: widget.type,
      order: widget.existing?.order ?? widget.order,
      en: _enCtrl.text.trim(),
      fr: _frCtrl.text.trim(),
      ar: _arCtrl.text.trim(),
      isActive: widget.existing?.isActive ?? true,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      await widget.repo.update(option.docId!, option);
    } else {
      await widget.repo.add(option);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final typeName = widget.type.displayName;
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

          // Header row with icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientgreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.type == AppOptionType.province
                      ? Icons.location_on_outlined
                      : Icons.work_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_isEdit ? 'Edit' : 'Add'} $typeName',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Fill in all three languages',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // EN
          _LangField(
            flag: '🇬🇧',
            lang: 'English',
            controller: _enCtrl,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 14),

          // FR
          _LangField(
            flag: '🇫🇷',
            lang: 'French',
            controller: _frCtrl,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 14),

          // AR
          _LangField(
            flag: '🇩🇿',
            lang: 'Arabic',
            controller: _arCtrl,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 28),

          // Save button
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isEdit ? 'Update' : 'Add',
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Directionality(
              textDirection: textDirection,
              child: TextField(
                controller: controller,
                textDirection: textDirection,
                decoration: InputDecoration(
                  hintText: 'Label in $lang...',
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