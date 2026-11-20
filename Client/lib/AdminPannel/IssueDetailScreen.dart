import 'package:client/AdminPannel/ReportIssueScreen.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/ReportIssueModel.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class IssueDetailScreen extends StatelessWidget {
  final ReportIssueModel issue;

  const IssueDetailScreen({super.key, required this.issue});

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

  Future<dynamic> _getReportedUser() {
    final jobSeekerRepo = JobSeekerRepository();
    final recruiterRepo = RecruiterRepository();
    if (issue.assignedTo == 'jobSeeker') {
      return jobSeekerRepo.getByUid(issue.userId);
    } else {
      return recruiterRepo.getByUid(issue.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColor;
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthProvider>().user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.issue_details_title),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          /// 🔥 STATUS HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(.95), color.withOpacity(.70)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderBadge(text: _getStatusTranslate(context, issue.status)),
                  const SizedBox(height: 14),

                  /// TITLE
                  Text(
                    issue.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// META
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _HeaderPill(icon: Icons.category, text: _getCategoryTranslate(context, issue.category)),
                      _HeaderPill(icon: Icons.flag, text: _getPriorityTranslate(context, issue.priority)),
                      _HeaderPill(
                        icon: Icons.schedule,
                        text: _formatDate(issue.createdAt),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                children: [
                  SizedBox(
                    
                    width: double.infinity,
                    child: _SectionCard(
                      title: l10n.issue_description_label,
                      child: Text(issue.description),
                    ),
                  ),

                  //button to reply
                  if (issue.adminComment != null &&
                      issue.adminComment!.trim().isNotEmpty)
                    const SizedBox(height: 20),

                  if (issue.adminComment != null &&
                      issue.adminComment!.trim().isNotEmpty)
                    _SectionCard(
                      title: l10n.response_label,
                      child: Text(
                        issue.adminComment!,
                        style: TextStyle(
                          height: 1.6,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (user.role == UserRole.admin) ...[
                    FutureBuilder(
                      future: _getReportedUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData) {
                          return Text(l10n.user_not_found_error);
                        }

                        final user = snapshot.data;

                        if (user is JobSeekerModel) {
                          return JobSeekerDetailCard(user: user);
                        } else if (user is Recruiter) {
                          return RecruiterDetailCard(user: user);
                        }

                        return const SizedBox();
                      },
                    ),

                    ElevatedButton(
                      
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportIssueScreen(
                              mode: ReportIssueMode.edit,
                              issue: issue,
                              isAdminView: true,
                            ),
                          ),
                        );
                      },
                      child: Text(l10n.reply_btn),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime createdAt) {
    final date = createdAt;
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

class JobSeekerDetailCard extends StatelessWidget {
  final JobSeekerModel user;

  const JobSeekerDetailCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: (user.logoUrl != null && user.logoUrl!.isNotEmpty)
                      ? NetworkImage(user.logoUrl!)
                      : null,
                  child: (user.logoUrl == null || user.logoUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.isNameVisible
                            ? "${user.firstName} ${user.lastName}"
                            : AppLocalizations.of(context)!.anonymous_job_seeker,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(user.desiredPosition),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            /// CONTACT
            _infoRow(Icons.email, user.email),
            _infoRow(Icons.phone, user.phoneNumber),

            const Divider(height: 24),

            /// LOCATION
            _infoRow(
              Icons.location_on,
              "${user.streetAddress}, ${user.city}, ${user.province}",
            ),

            const Divider(height: 24),

            /// SKILLS
            Text("Skills", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: user.skills.map((e) {
            //     //final color = e == SkillStatus.verified
            //         ? Colors.green
            //         // : e.value == true;//SkillStatus.pending
            //         // ? Colors.orange
            //         // : Colors.red;

            //     return Chip(
            //       label: Text("${e.key} • ${e.value}"),
            //       backgroundColor: color.withOpacity(.15),
            //     );
            //   }).toList(),
            // ),

            if (user.educationBackground != null) ...[
              const Divider(height: 24),
              Text("Education"),
              Text(user.educationBackground!),
            ],

            if (user.experienceDetails != null) ...[
              const Divider(height: 24),
              Text("Experience"),
              Text(user.experienceDetails!),
            ],
          ],
        ),
      ),
    );
  }
}

class RecruiterDetailCard extends StatelessWidget {
  final Recruiter user;

  const RecruiterDetailCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: (user.logoUrl != null && user.logoUrl!.isNotEmpty)
                      ? NetworkImage(user.logoUrl!)
                      : null,
                  child: (user.logoUrl == null || user.logoUrl!.isEmpty)
                      ? Image.asset(
                          'assets/logo.png',
                          width: 18, // set your desired width
                          height: 18, // set your desired height
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.pharmacyName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "${user.pharmacistFirstName} ${user.pharmacistLastName}",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            /// LOCATION
            _infoRow(
              Icons.location_on,
              "${user.streetAddress}, ${user.city}, ${user.province}",
            ),

            const Divider(height: 24),

            /// STATUS
            _infoRow(
              Icons.verified,
              user.isActive
                  ? AppLocalizations.of(context)!.active_recruiter
                  : AppLocalizations.of(context)!.inactive_recruiter,
            ),

            const Divider(height: 24),

            /// META
            _infoRow(
              Icons.calendar_today,
              "${AppLocalizations.of(context)!.joined_label}: ${user.createdAt.toLocal().toString().split(' ').first}",
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _HeaderBadge extends StatelessWidget {
  final String text;

  const _HeaderBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

// ===================== CARD =====================
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}
