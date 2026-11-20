
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/ReportIssueModel.dart';
import 'package:client/Server/Repo/ReportIssueRepository.dart';
import '../l10n/app_localizations.dart';

import 'package:client/Server/Services/NotificationService.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import '../Server/Enums/UserRole.dart';

enum ReportIssueMode { create, edit }

class ReportIssueScreen extends StatefulWidget {
  final ReportIssueMode mode;
  final ReportIssueModel? issue;
  final bool isAdminView;
  const ReportIssueScreen({super.key, required this.mode, this.issue, this.isAdminView = false});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _repo = ReportIssueRepository();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final adminComment=TextEditingController();
  String? category;
  String priority = IssuePriority.medium;

  bool loading = true;

  bool get isCreate => widget.mode == ReportIssueMode.create;

  final categories = [
    IssueCategory.crash,
    IssueCategory.ui,
    IssueCategory.performance,
    IssueCategory.payment,
    IssueCategory.loginAuth,
    IssueCategory.other,
  ];

  final priorities = [
    IssuePriority.low,
    IssuePriority.medium,
    IssuePriority.high,
    IssuePriority.critical,
  ];

  @override
  void initState() {
    super.initState();
    _loadIssue();
  }

  void _loadIssue() {
    if (widget.issue != null) {
      final i = widget.issue!;
      titleCtrl.text = i.title;
      descCtrl.text = i.description;
      if (!isCreate && widget.issue?.adminComment != null) {
        adminComment.text = widget.issue!.adminComment!;
      }

      category = i.category;
      priority = i.priority;
    }
    setState(() => loading = false);
  }

  String _getCategoryTranslate(String cat) {
    final l10n = AppLocalizations.of(context)!;
    switch (cat) {
      case IssueCategory.crash:
        return l10n.cat_crash;
      case IssueCategory.ui:
        return l10n.cat_ui_issue;
      case IssueCategory.performance:
        return l10n.cat_performance;
      case IssueCategory.payment:
        return l10n.cat_payment;
      case IssueCategory.loginAuth:
        return l10n.cat_login_auth;
      case IssueCategory.other:
      default:
        return l10n.cat_other;
    }
  }

  String _getPriorityTranslate(String prio) {
    final l10n = AppLocalizations.of(context)!;
    switch (prio) {
      case IssuePriority.low:
        return l10n.priority_low;
      case IssuePriority.medium:
        return l10n.priority_medium;
      case IssuePriority.high:
        return l10n.priority_high;
      case IssuePriority.critical:
        return l10n.priority_critical;
      default:
        return prio;
    }
  }

  bool _validate() {
    final l10n = AppLocalizations.of(context)!;
    if (titleCtrl.text.trim().isEmpty) {
      _error(l10n.enter_issue_title_error);
      return false;
    }
    if (category == null) {
      _error(l10n.select_category_error);
      return false;
    }
    if (descCtrl.text.trim().isEmpty) {
      _error(l10n.describe_issue_error);
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => loading = true);

    final user = context.read<AuthProvider>().user!;
    final issue = ReportIssueModel(
      docId: widget.issue?.docId,
      userId: isCreate ? user.userId : widget.issue!.userId,
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      adminComment: adminComment.text.trim(),
      category: category!,
      priority: priority,
      status: isCreate ? IssueStatus.open : widget.issue!.status,
      assignedTo: user.role.toString(), // unassigned
      createdAt: widget.issue?.createdAt ?? DateTime.now(),
      updatedAt: isCreate ? null : DateTime.now(),
    );

    String? docId;
    if (isCreate) {
      docId = await _repo.add(issue);
    } else {
      docId = issue.docId;
      await _repo.update(docId!, issue);
    }

    if (isCreate) {
      await _sendNotifications(issue.copyWith(docId: docId), false);
    }

    setState(() => loading = false);
    Navigator.pop(context);
  }

  Future<void> _closeIssue() async {
    if (!_validate()) return;

    setState(() => loading = true);

    final issue = ReportIssueModel(
      docId: widget.issue?.docId,
      userId: widget.issue!.userId,
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      adminComment: adminComment.text.trim(),
      category: category!,
      priority: priority,
      status: IssueStatus.resolved,
      assignedTo: widget.issue!.assignedTo,
      createdAt: widget.issue!.createdAt,
      updatedAt: DateTime.now(),
    );

    await _repo.update(issue.docId!, issue);

    await _sendNotifications(issue, true);

    setState(() => loading = false);
    Navigator.pop(context);
  }

  Future<void> _sendNotifications(ReportIssueModel issue, bool isResolved) async {
    try {
      final l10n = AppLocalizations.of(context)!;
      final adminRepo = AdminRepository();
      final admins = await adminRepo.getAll();

      // 1. Notify User
      String userTitle = isResolved ? l10n.notif_issue_resolved_title : l10n.notif_issue_reported_title;
      String userDesc = isResolved 
          ? l10n.notif_issue_resolved_desc(issue.title) 
          : l10n.notif_issue_reported_desc(issue.title);

      await NotificationService.sendToUser(
        targetUserId: issue.userId,
        type: isResolved ? 'issue_resolved' : 'issue_reported',
        title: userTitle,
        description: userDesc,
        targetId: issue.docId,
        targetType: 'issue',
        payload: {'title': issue.title},
      );

      // 2. Notify ALL Admins
      String adminTitle = isResolved ? l10n.notif_admin_issue_resolved_title : l10n.notif_admin_new_issue_title;
      String adminDesc = isResolved 
          ? l10n.notif_admin_issue_resolved_desc(issue.title) 
          : l10n.notif_admin_new_issue_desc(issue.title);

      for (var admin in admins) {
        await NotificationService.sendToUser(
          targetUserId: admin.userId,
          type: isResolved ? 'issue_resolved' : 'issue_reported',
          title: adminTitle,
          description: adminDesc,
          targetId: issue.docId,
          targetType: 'issue',
          payload: {'title': issue.title},
        );
      }
    } catch (e) {
      debugPrint("Error sending notifications: $e");
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = context.read<AuthProvider>().user!;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isCreate ? l10n.report_issue_title : l10n.edit_issue_title),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        child: Column(
          children: [
            _SectionCard(
              title: l10n.issue_details_label,
              child: Column(
                children: [
                  _TextInputField(
                    label: l10n.issue_title_label,
                    controller: titleCtrl,
                    hint: l10n.issue_title_hint,
                  ),

                  const SizedBox(height: 16),

                  _DropdownField(
                    label: l10n.issue_category_label,
                    value: category,
                    items: categories,
                    itemLabel: _getCategoryTranslate,
                    onChanged: (v) => setState(() => category = v),
                  ),
                  const SizedBox(height: 16),

                  _DropdownField(
                    label: l10n.issue_priority_label,
                    value: priority,
                    items: priorities,
                    itemLabel: _getPriorityTranslate,
                    onChanged: (v) => setState(() => priority = v!),
                  ),
                  const SizedBox(height: 16),

                  _MultilineField(
                    label: l10n.issue_description_label,
                    controller: descCtrl,
                    hint: l10n.issue_description_hint,
                  ),
                  const SizedBox(height: 16),

                  if(user.role==UserRole.admin)...[
                    _MultilineField(
                    label: l10n.admin_comment_label,
                    controller: adminComment,
                    hint: l10n.issue_description_hint,
                  ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _customButton(
                    text: isCreate ? l10n.submit_issue_btn : l10n.update_issue_btn,
                    size: MediaQuery.of(context).size,
                    gradient: AppColors.gradientgreen,
                    shadowColor: AppColors.green,
                    onPressed: _submit,
                  ),
                  if(!isCreate && user.role == UserRole.admin && widget.issue?.status != IssueStatus.resolved)...[
                    const SizedBox(height: 12),
                    _customButton(
                      text: l10n.close_issue_btn,
                      size: MediaQuery.of(context).size,
                      gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
                      shadowColor: Colors.blue,
                      onPressed: _closeIssue,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _TextInputField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultilineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _MultilineField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: AppColors.gradientgreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _TextField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== PREMIUM DROPDOWN FIELD =====================
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String Function(String) itemLabel;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(itemLabel(e))),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== CARD =====================
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ===================== BUTTON =====================
Widget _customButton({
  required String text,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
