import 'package:client/AdminPannel/IssueDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/ReportIssueModel.dart';
import 'package:client/Server/Repo/ReportIssueRepository.dart';
import '../l10n/app_localizations.dart';

class MyReportedIssuesScreen extends StatefulWidget {
  final bool isAdminView;
  const MyReportedIssuesScreen({super.key, required this.isAdminView});

  @override
  State<MyReportedIssuesScreen> createState() => _MyReportedIssuesScreenState();
}

class _MyReportedIssuesScreenState extends State<MyReportedIssuesScreen> {
  final _repo = ReportIssueRepository();
  late Future<List<ReportIssueModel>> _future;

  @override
  void initState() {
    super.initState();
     if (widget.isAdminView) {
      // 🔥 Admin → get ALL issues
      _future = _repo.getAll();
    } else {
     final user = context.read<AuthProvider>().user!;
     _future = _repo.getByUserId(user.userId);
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(widget.isAdminView
              ? AppLocalizations.of(context)!.reported_issues_admin_title
              : AppLocalizations.of(context)!.my_reported_issues_title),
          backgroundColor: AppColors.background,
          bottom: TabBar(
            indicatorColor: AppColors.green,
            labelColor: AppColors.green,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tabs_open),
              Tab(text: AppLocalizations.of(context)!.tabs_closed),
            ],
          ),
        ),
        body: FutureBuilder<List<ReportIssueModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _ErrorState(
                  message: AppLocalizations.of(context)!.failed_load_issues_error);
            }

            final issues = snapshot.data ?? [];

            if (issues.isEmpty) {
              return _EmptyState();
            }

            // Filter issues for each tab
            final openIssues = issues
                .where((i) =>
                    i.status == IssueStatus.open ||
                    i.status == IssueStatus.inProgress)
                .toList();
            final closedIssues = issues
                .where((i) =>
                    i.status == IssueStatus.resolved ||
                    i.status == IssueStatus.rejected)
                .toList();

            return TabBarView(
              children: [
                _buildIssuesList(openIssues),
                _buildIssuesList(closedIssues),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIssuesList(List<ReportIssueModel> list) {
    if (list.isEmpty) {
      return _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final issue = list[index];
        return _IssueCard(issue: issue);
      },
    );
  }
}

class _IssueCard extends StatelessWidget {
  final ReportIssueModel issue;

  const _IssueCard({required this.issue});

  Color get statusColor {
    switch (issue.status) {
      case IssueStatus.open:
        return Colors.orange;
      case IssueStatus.inProgress:
        return Colors.blue;
      case IssueStatus.resolved:
        return AppColors.green;
      case IssueStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusTranslate(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case IssueStatus.open:
        return l10n.status_open;
      case IssueStatus.inProgress:
        return l10n.status_in_progress;
      case IssueStatus.resolved:
        return l10n.status_resolved;
      case IssueStatus.rejected:
        return l10n.status_rejected;
      default:
        return status;
    }
  }

  String _getCategoryTranslate(BuildContext context, String cat) {
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

  String _getPriorityTranslate(BuildContext context, String prio) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IssueDetailScreen(issue: issue),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppUI.card,
          borderRadius: BorderRadius.circular(AppUI.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            /// 🔥 STATUS STRIP
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor,
                    statusColor.withOpacity(.6),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppUI.radius),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE + STATUS
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          issue.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusChip(
                        text: _getStatusTranslate(context, issue.status),
                        color: statusColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// CATEGORY & PRIORITY
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SoftChip(text: _getCategoryTranslate(context, issue.category)),
                      _SoftChip(
                        text: _getPriorityTranslate(context, issue.priority),
                        color: AppColors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// DESCRIPTION
                  Text(
                    issue.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// DATE
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(issue.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
class _SoftChip extends StatelessWidget {
  final String text;
  final Color color;

  const _SoftChip({
    required this.text,
    this.color = Colors.blueGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;

  const _Tag({required this.text, this.color = Colors.blueGrey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bug_report_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.no_issues_reported_title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.report_problem_hint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
