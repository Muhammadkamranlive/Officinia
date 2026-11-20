import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillMetaRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';

import '../../l10n/app_localizations.dart';

class RecruiterSkillVerificationScreen extends StatefulWidget {
  final String jobSeekerId;
  final SkillVerificationRequest skillRequest;

  const RecruiterSkillVerificationScreen({
    super.key,
    required this.jobSeekerId,
    required this.skillRequest,
  });

  @override
  State<RecruiterSkillVerificationScreen> createState() =>
      _RecruiterSkillVerificationScreenState();
}

class _RecruiterSkillVerificationScreenState
    extends State<RecruiterSkillVerificationScreen> {
  final JobSeekerRepository _jobSeekerRepo     = JobSeekerRepository();
  final SkillMetaRepository _skillMetaRepo      = SkillMetaRepository();
  final SkillVerificationRequestRepository _requestRepo =
      SkillVerificationRequestRepository();

  late Future<JobSeekerModel?> _jobSeekerFuture;
  late Future<List<SkillVerificationMeta>> _skillMetasFuture;

  // Track in-progress actions per skill to prevent double-taps
  final Set<String> _processingSkills = {};

  @override
  void initState() {
    super.initState();
    _jobSeekerFuture = _jobSeekerRepo.getByUid(widget.jobSeekerId);
    _loadSkillMetas();
  }

  void _loadSkillMetas() {
    _skillMetasFuture = _skillMetaRepo.getPendingSkillsForRecruiter(
      jobSeekerId: widget.jobSeekerId,
      recruiterId: widget.skillRequest.recruiterId,
    );
  }

  Future<void> _verifySkill(String skill) async {
    if (_processingSkills.contains(skill)) return;
    setState(() => _processingSkills.add(skill));

    try {
      await _skillMetaRepo.verifySkill(
        jobSeekerId: widget.jobSeekerId,
        skill:       skill,
        recruiterId: widget.skillRequest.recruiterId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingSkills.remove(skill);
          _loadSkillMetas();
        });
      }
    }
  }

  Future<void> _rejectSkill(String skill) async {
    if (_processingSkills.contains(skill)) return;
    setState(() => _processingSkills.add(skill));

    try {
      await _skillMetaRepo.rejectSkill(
        jobSeekerId: widget.jobSeekerId,
        skill:       skill,
        recruiterId: widget.skillRequest.recruiterId,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingSkills.remove(skill);
          _loadSkillMetas();
        });
      }
    }
  }

  bool _completing = false;

  Future<void> _completeVerification() async {
    if (_completing) return;
    setState(() => _completing = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      final notificationRepo = NotificationRepository();

      await notificationRepo.add(NotificationModel(
        userId:      widget.skillRequest.jobSeekerId,
        type:        'skill_verified',
        title:       l10n.skill_verification_completed_notif_title,
        description: l10n.skill_verification_completed_notif_desc,
        targetId:    widget.skillRequest.docId,
        targetType:  'localNotification',
        route:       AppRoutes.notifications,
        isRead:      false,
        isSent:      false,
        createdAt:   DateTime.now(),
      ));

      await _requestRepo.update(
        widget.skillRequest.docId!,
        SkillVerificationRequest(
          jobSeekerId: widget.skillRequest.jobSeekerId,
          recruiterId: widget.skillRequest.recruiterId,
          jobId:       widget.skillRequest.jobId,
          createdAt:   widget.skillRequest.createdAt,
          status:      'Completed',
          docId:       widget.skillRequest.docId,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failed_to_update(e.toString())),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.verify_jobseeker_skills_title,
          style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.darkGreen),
      ),
      body: FutureBuilder<JobSeekerModel?>(
        future: _jobSeekerFuture,
        builder: (context, jsSnapshot) {
          if (jsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (jsSnapshot.hasError || jsSnapshot.data == null) {
            return Center(
              child: Text(
                  '${l10n.failed_to_load_requests}: ${jsSnapshot.error ?? l10n.anonymous_candidate}'),
            );
          }

          final jobSeeker = jsSnapshot.data!;

          return FutureBuilder<List<SkillVerificationMeta>>(
            future: _skillMetasFuture,
            builder: (context, skillSnapshot) {
              if (skillSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (skillSnapshot.hasError) {
                return Center(
                    child: Text('${l10n.failed_to_load_requests}: ${skillSnapshot.error}'));
              }

              final skills = skillSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Job seeker info card ─────────────────
                    _JobSeekerInfoCard(jobSeeker: jobSeeker, l10n: l10n),

                    const SizedBox(height: 20),

                    // ── Skills section ───────────────────────
                    if (skills.isEmpty)
                      _AllReviewedCard(l10n: l10n)
                    else ...[
                      _SectionLabel(text: l10n.skills_to_review_label),
                      const SizedBox(height: 10),
                      ...skills.map((meta) => _SkillReviewCard(
                            meta:        meta,
                            isProcessing: _processingSkills.contains(meta.skill),
                            onVerify:    () => _verifySkill(meta.skill),
                            onReject:    () => _rejectSkill(meta.skill),
                            l10n:        l10n,
                          )),
                    ],

                    const SizedBox(height: 20),

                    // ── Note from job seeker (optional) ──────
                    _SectionLabel(text: l10n.note_from_jobseeker_label),
                    const SizedBox(height: 8),
                    _NoteBox(
                      // note is fully optional — show placeholder if null/empty
                      note: (widget.skillRequest.note?.trim().isEmpty ?? true)
                          ? null
                          : widget.skillRequest.note,
                      l10n: l10n,
                    ),

                    const SizedBox(height: 28),

                    // ── Complete button ───────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // No validation gate — always tappable
                        onPressed:
                            _completing ? null : _completeVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenCeladon,
                          disabledBackgroundColor:
                              AppColors.greenCeladon.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _completing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.mark_verification_completed_btn,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black87,
        ),
      );
}

class _AllReviewedCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _AllReviewedCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              size: 40, color: AppColors.darkGreen.withOpacity(0.7)),
          const SizedBox(height: 10),
          Text(
            l10n.all_skills_reviewed_msg,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkillReviewCard extends StatelessWidget {
  final SkillVerificationMeta meta;
  final bool         isProcessing;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  final AppLocalizations l10n;

  const _SkillReviewCard({
    required this.meta,
    required this.isProcessing,
    required this.onVerify,
    required this.onReject,
    required this.l10n,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Verified':  return Colors.green;
      case 'Rejected':  return Colors.red;
      default:          return Colors.orange;
    }
  }

  String _localizedStatus(String status) {
    switch (status) {
      case 'Verified':  return l10n.verify_action;
      case 'Rejected':  return l10n.reject_action;
      default:          return l10n.pending_review_status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Skill name + status badge ──────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  meta.skill,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(meta.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _localizedStatus(meta.status),
                  style: TextStyle(
                    color:      _statusColor(meta.status),
                    fontWeight: FontWeight.w600,
                    fontSize:   12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Verified / rejected counts ─────────────────────
          Row(
            children: [
              Icon(Icons.check_circle,
                  size: 15, color: Colors.green.shade700),
              const SizedBox(width: 4),
              Text(l10n.verified_count_label(meta.verifiedCount.toString()),
                  style: TextStyle(
                      fontSize: 12, color: Colors.green.shade700)),
              const SizedBox(width: 14),
              Icon(Icons.cancel,
                  size: 15, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(l10n.rejected_count_label(meta.rejectedCount.toString()),
                  style: TextStyle(
                      fontSize: 12, color: Colors.red.shade700)),
            ],
          ),

          const SizedBox(height: 14),

          // ── Action buttons ─────────────────────────────────
          isProcessing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onVerify,
                        icon:  const Icon(Icons.check, size: 17),
                        label: Text(l10n.verify_action),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenCeladon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon:  const Icon(Icons.close, size: 17),
                        label: Text(l10n.reject_action),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  final String? note;
  final AppLocalizations l10n;
  const _NoteBox({this.note, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final hasNote = note != null && note!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasNote ? Colors.grey.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasNote
              ? Colors.grey.shade200
              : Colors.grey.shade300,
        ),
      ),
      child: Text(
        hasNote ? note! : l10n.no_note_provided,
        style: TextStyle(
          fontSize:  14,
          height:    1.5,
          color:     hasNote ? Colors.black87 : Colors.grey.shade500,
          fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }
}


class _JobSeekerInfoCard extends StatelessWidget {
  final JobSeekerModel jobSeeker;
  final AppLocalizations l10n;
  const _JobSeekerInfoCard({required this.jobSeeker, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final name = jobSeeker.isNameVisible
        ? '${jobSeeker.firstName} ${jobSeeker.lastName}'
        : l10n.anonymous_candidate;
    final initials = jobSeeker.isNameVisible
        ? '${jobSeeker.firstName[0]}${jobSeeker.lastName[0]}'.toUpperCase()
        : 'AC';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.green, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        
      
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            // ── Green header ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: [AppColors.green, AppColors.green, AppColors.greenCeladon],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD5F5E3), Color(0xFFA9DFBF)],
                          ),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.8), width: 2.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A6B4A),
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 13, height: 13,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1C40F),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 14),

                  // Name + job title + status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Job title pill
                        if (jobSeeker.desiredPosition.isNotEmpty ?? false)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.work_outline,
                                    size: 11, color: Colors.white70),
                                const SizedBox(width: 5),
                                Text(
                                  jobSeeker.desiredPosition,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greenCeladon,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.pending_review_status,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A6B4A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Info grid ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _InfoTile(
                              icon: Icons.phone_outlined,
                              label: l10n.phone_label,
                              value: jobSeeker.phoneNumber)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _InfoTile(
                              icon: Icons.location_city_outlined,
                              label: l10n.city_label,
                              value: jobSeeker.city)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  Row(
                    children: [
                      Expanded(
                          child: _InfoTile(
                              icon: Icons.school_outlined,
                              label: l10n.education_label,
                              value: jobSeeker.educationBackground ?? l10n.na_value)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _InfoTile(
                                icon: Icons.work_outline,
                              label: l10n.experience_label,
                              value: jobSeeker.experienceDetails ?? l10n.na_value)
                      )
                    
                  ],
                  
              ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _InfoTile(
                              icon: Icons.map_outlined,
                              label: l10n.wilaya_label,
                              value: jobSeeker.province)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEAFAF1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF27AE60)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}