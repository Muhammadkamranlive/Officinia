

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JobApplicationTrackingScreen.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

import '../../Server/Repo/JobList/JobSearchRepository.dart';
import '../RecruiterAccountScreen/PendingRequestsSkillverification.dart';
import '../RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import '../../AdminPannel/IssueDetailScreen.dart';
import '../../Server/Model/ReportIssueModel.dart';
import '../../Server/Repo/ReportIssueRepository.dart';

// ── Import your job-seeker-side "My Applications" screen here ────────────────
// Replace with your actual import path:

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get _isJobRelated {
    final type = notification.type.toLowerCase();
    return type.contains('job') &&
        notification.targetId != null &&
        notification.targetId!.isNotEmpty;
  }

  bool get _isSkillRelated =>
      notification.type.toLowerCase().contains('skill');

  bool get _isIssueRelated =>
      notification.type.toLowerCase().contains('issue') &&
      notification.targetId != null &&
      notification.targetId!.isNotEmpty;

  IconData _getIcon(String type) {
    switch (type) {
      case 'login':            return Icons.login;
      case 'logout':           return Icons.logout;
      case 'payment':          return Icons.payment;
      case 'job_post':         return Icons.campaign;
      case 'job_apply':        return Icons.person_add_alt;
      case 'Job_Application':  return Icons.work_outline;
      case 'issue_reported':
      case 'issue_resolved':   return Icons.bug_report;
      default:                 return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'login':            return Colors.green;
      case 'logout':           return Colors.red;
      case 'payment':          return AppColors.green;
      case 'job_post':         return Colors.orange;
      case 'job_apply':        return Colors.blue;
      case 'Job_Application':  return AppColors.greenCeladon;
      case 'issue_reported':   return Colors.orange;
      case 'issue_resolved':   return AppColors.green;
      default:                 return AppColors.darkGreen;
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}  "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  String _localizedTitle(BuildContext context, NotificationModel n) {
    final l10n = AppLocalizations.of(context)!;
    switch (n.type) {
      case 'job_post':
        return l10n.notif_job_posted_title;
      case 'job_apply':
      case 'Job_Application':
        return l10n.notif_job_apply_title;
      case 'skill_verified':
      case 'skill_verification':
        return l10n.notif_skill_verified_title;
      case 'payment':
        return l10n.notif_payment_success_title;
      case 'login':
        return l10n.notif_login_title;
      case 'logout':
        return l10n.notif_logout_title;
      case 'issue_reported':
        return l10n.notif_issue_reported_title;
      case 'issue_resolved':
        return l10n.notif_issue_resolved_title;
      default:
        return n.title; // Fallback to DB title
    }
  }

  String _localizedDescription(BuildContext context, NotificationModel n) {
    final l10n = AppLocalizations.of(context)!;
    final p = n.payload ?? {};
    switch (n.type) {
      case 'job_post':
        return l10n.notif_job_posted_desc(p['jobTitle'] ?? 'Job');
      case 'job_apply':
      case 'Job_Application':
        return l10n.notif_job_apply_desc(p['jobTitle'] ?? 'Job');
      case 'skill_verified':
      case 'skill_verification':
        return l10n.notif_skill_verified_desc(p['skillName'] ?? 'Skill');
      case 'payment':
        return l10n.notif_payment_success_desc(p['planName'] ?? 'Plan');
      case 'login':
        final timeStr = "${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}";
        return l10n.notif_login_desc(timeStr);
      case 'logout':
        return l10n.notif_logout_desc;
      case 'issue_reported':
        return l10n.notif_issue_reported_desc(p['title'] ?? 'Issue');
      case 'issue_resolved':
        return l10n.notif_issue_resolved_desc(p['title'] ?? 'Issue');
      default:
        return n.description; // Fallback to DB description
    }
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final color = _getColor(notification.type);

    // Read role once — safe because AuthProvider never changes mid-session
    final role = context.read<AuthProvider>().user?.role;
    final isRecruiter = role == UserRole.recruiter || role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.notification_detail,
          style: const TextStyle(color: AppColors.darkGreen),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + Title ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _localizedTitle(context, notification),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Timestamp ──────────────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  _formatDate(notification.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Description ────────────────────────────────────────────────
            Text(
              _localizedDescription(context, notification),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),

            const SizedBox(height: 32),

            // ── ACTION BUTTONS ─────────────────────────────────────────────

            // 1. Job-related notification
            if (_isJobRelated)
              _ViewJobButton(
                targetId: notification.targetId!,
              ),

            // 1.1 Issue-related notification
            if (_isIssueRelated)
              _ViewIssueButton(
                targetId: notification.targetId!,
              ),

            // 2. Skill-related notification
            //    Recruiter / Admin → Pending Skill Verification screen
            //    Job Seeker        → My Applications screen
            if (_isSkillRelated) ...[
              if (_isJobRelated) const SizedBox(height: 12),
              isRecruiter
                  ? _ActionButton(
                      icon:  Icons.verified_user_outlined,
                      label: AppLocalizations.of(context)!.see_skill_requests,
                      color: AppColors.darkGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PendingSkillVerificationScreen(),
                        ),
                      ),
                    )
                  : _ActionButton(
                      icon:  Icons.assignment_outlined,
                      label: AppLocalizations.of(context)!.view_my_applications,
                      color: AppColors.greenCeladon,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JobApplicationTrackingScreen(),
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  View Issue Button — async, shows loading while fetching issue details
// ─────────────────────────────────────────────────────────────────────────────
class _ViewIssueButton extends StatefulWidget {
  final String targetId;
  const _ViewIssueButton({required this.targetId});

  @override
  State<_ViewIssueButton> createState() => _ViewIssueButtonState();
}

class _ViewIssueButtonState extends State<_ViewIssueButton> {
  bool _loading = false;

  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final repo = ReportIssueRepository();
      final issue = await repo.getById(widget.targetId);

      if (!mounted) return;

      if (issue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Issue not found or removed")),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IssueDetailScreen(issue: issue),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _open,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.bug_report_outlined, color: Colors.white),
        label: Text(
          _loading 
              ? AppLocalizations.of(context)!.loading_dots 
              : AppLocalizations.of(context)!.view_details,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCeladon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  View Job Button  — async, shows loading while fetching job details
// ─────────────────────────────────────────────────────────────────────────────
class _ViewJobButton extends StatefulWidget {
  final String targetId;
  const _ViewJobButton({required this.targetId});

  @override
  State<_ViewJobButton> createState() => _ViewJobButtonState();
}

class _ViewJobButtonState extends State<_ViewJobButton> {
  bool _loading = false;

  Future<void> _open() async {
    setState(() => _loading = true);
    try {
      final repo           = JobSearchRepository();
      final jobWithRecruiter =
          await repo.getJobWithRecruiterByJobId(widget.targetId);

      if (!mounted) return;

      if (jobWithRecruiter == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.job_not_found_error)),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RecruiterJobDetailScreen(job: jobWithRecruiter),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _open,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.work_outline, color: Colors.white),
        label: Text(
          _loading ? AppLocalizations.of(context)!.loading_dots : AppLocalizations.of(context)!.view_job,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCeladon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Generic action button (skill-related)
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}