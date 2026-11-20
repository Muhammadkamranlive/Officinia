import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';
import '../../l10n/app_localizations.dart';

class SendSkillVerificationRequestScreen extends StatefulWidget {
  const SendSkillVerificationRequestScreen({super.key});

  @override
  State<SendSkillVerificationRequestScreen> createState() =>
      _SendSkillVerificationRequestScreenState();
}

class _SendSkillVerificationRequestScreenState
    extends State<SendSkillVerificationRequestScreen> {
  final appRepo = JobApplicationRepository();
  final requestRepo = SkillVerificationRequestRepository();

  late String jobSeekerId;

  @override
  void initState() {
    super.initState();
    jobSeekerId = context.read<AuthProvider>().user!.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.skill_verification_requests_title,
          style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<JobApplicationWithJob>>(
        stream: appRepo.streamApplicationsWithJobsForCandidate(jobSeekerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          // Filter only accepted applications with chat enabled
          final data = (snapshot.data ?? [])
              .where((e) => e.application.allowChat)
              .toList();

          if (data.isEmpty) return _EmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];

              return FutureBuilder<SkillVerificationRequest?>(
                future: requestRepo.getRequestForJobAndRecruiter(
                  jobSeekerId: jobSeekerId,
                  recruiterId: item.job.userId,
                  jobId: item.job.docId!,
                ),
                builder: (_, reqSnap) {
                  if (reqSnap.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final existingRequest = reqSnap.data;

                  return SkillVerificationRequestCard(
                    item: item,
                    existingRequest: existingRequest,
                    onSendRequest: () async {
                      await _sendVerificationRequest(item);
                      setState(() {}); // Refresh UI
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendVerificationRequest(JobApplicationWithJob item) async {
    // Show note dialog
    final note = await _showNoteDialog();
    if (note == null) return; // User cancelled

    try {
      // Create verification request
      final request = SkillVerificationRequest(
        jobSeekerId: jobSeekerId,
        recruiterId: item.job.userId,
        jobId: item.job.docId!,
        createdAt: DateTime.now(),
        status: 'Pending',
        note: note.isEmpty ? null : note,
      );

      await requestRepo.submitRequest(request);

      // Send notification to job seeker
      final notificationRepo = NotificationRepository();
      await notificationRepo.add(NotificationModel(
        userId: jobSeekerId,
        type: 'skill_verification',
        title: 'Skill Verification Requested',
        description:
            'Your skill verification request has been sent to ${item.job.jobTitle} recruiter.',
        payload: {
          'jobTitle': item.job.jobTitle,
        },
        targetId: item.application.jobId,
        targetType: 'localNotification',
        route: AppRoutes.notifications,
        isRead: false,
        isSent: false,
        createdAt: DateTime.now(),
      ));

      // Send notification to recruiter
      await notificationRepo.add(NotificationModel(
        userId: item.job.userId,
        type: 'skill_verification',
        title: 'Skill Verification Request',
        description:
            'A job seeker has requested skill verification for ${item.job.jobTitle}.',
        payload: {
          'jobTitle': item.job.jobTitle,
        },
        targetId: item.application.jobId,
        targetType: 'localNotification',
        route: AppRoutes.notifications,
        isRead: false,
        isSent: false,
        createdAt: DateTime.now(),
      ));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.verification_request_sent_success),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failed_to_send_request(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _showNoteDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.add_note_dialog_title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.add_note_dialog_hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.dialog_cancel_btn),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.send_request_btn),
          ),
        ],
      ),
    );
  }
}

class SkillVerificationRequestCard extends StatelessWidget {
  final JobApplicationWithJob item;
  final SkillVerificationRequest? existingRequest;
  final VoidCallback onSendRequest;

  const SkillVerificationRequestCard({
    super.key,
    required this.item,
    required this.existingRequest,
    required this.onSendRequest,
  });

  JobApplicationModel get app => item.application;
  JobOffer get job => item.job;

  IconData get jobIcon {
    switch (job.jobTitle) {
      case 'Pharmacist':
        return Icons.medication_outlined;
      case 'Gerant':
        return Icons.store_outlined;
      case 'Physician':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.work_outline;
    }
  }

  Color get statusColor {
    if (existingRequest == null) return Colors.grey;
    switch (existingRequest!.status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String statusText(BuildContext context) {
    if (existingRequest == null) return AppLocalizations.of(context)!.status_not_requested;
    if (existingRequest!.status == 'Pending') return AppLocalizations.of(context)!.status_pending;
    if (existingRequest!.status == 'Completed') return AppLocalizations.of(context)!.status_completed;
    return existingRequest!.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.greenCeladon.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 HEADER (Job Info)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.greenCeladon.withOpacity(0.12),
                child: Icon(jobIcon, color: AppColors.greenCeladon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.jobType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              /// STATUS CHIP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  statusText(context),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔹 PURPOSE BOX
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenCeladon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 18,
                  color: AppColors.greenCeladon,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.request_skill_verification_purpose,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 ACTIONS
          if (existingRequest == null) ...[
            // No request sent yet
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSendRequest,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.send_skill_verification_request_btn,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenCeladon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ] else if (existingRequest!.status == 'Pending') ...[
            // Request pending
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_empty, 
                        color: Colors.orange, 
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.verification_request_pending_desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ChatWithRecruiterButton(job: job),
              ],
            ),
          ] else if (existingRequest!.status == 'Completed') ...[
            // Request completed
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, 
                        color: Colors.green, 
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.verification_completed_desc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ChatWithRecruiterButton(job: job),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ChatWithRecruiterButton extends StatefulWidget {
  final JobOffer job;

  const ChatWithRecruiterButton({super.key, required this.job});

  @override
  State<ChatWithRecruiterButton> createState() =>
      _ChatWithRecruiterButtonState();
}

class _ChatWithRecruiterButtonState extends State<ChatWithRecruiterButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleChat,
        icon: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chat_bubble_outline),
        label: Text(
          AppLocalizations.of(context)!.chat_with_recruiter_btn,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.greenCeladon),
          foregroundColor: AppColors.greenCeladon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChat() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      if (auth.user == null) return;

      final recruiterRepo = RecruiterRepository();
      final recruiter = await recruiterRepo.getByUid(widget.job.userId);

      if (recruiter == null) {
        throw Exception("Recruiter not found");
      }

      final jobSeekerId = auth.user!.userId;
      final recruiterId = widget.job.userId;

      final chatService = ChatService();
      final chatId = await chatService.getOrCreateChat(
        recruiterId,
        jobSeekerId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserId: recruiterId,
            personName:
                '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failed_to_open_chat(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.no_applications_yet_title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.apply_to_jobs_for_verification_desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Premium shadow effect
final List<BoxShadow> premiumShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  ),
];