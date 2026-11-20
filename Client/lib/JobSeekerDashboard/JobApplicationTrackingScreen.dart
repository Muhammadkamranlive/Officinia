import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:provider/provider.dart';

import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';
import '../../l10n/app_localizations.dart';

class JobApplicationTrackingScreen extends StatefulWidget {
  const JobApplicationTrackingScreen({super.key});

  @override
  State<JobApplicationTrackingScreen> createState() =>
      _JobApplicationTrackingScreenState();
}

class _JobApplicationTrackingScreenState
    extends State<JobApplicationTrackingScreen> {
  final repo = JobApplicationRepository();
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = context.read<AuthProvider>().user!.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.my_applications_title, style: const TextStyle( color: AppColors.darkGreen,fontWeight: FontWeight.w600,))),
      body: StreamBuilder<List<JobApplicationWithJob>>(
        stream: repo.streamApplicationsWithJobsForCandidate(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.failed_to_load_applications));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) => JobApplicationCard(item: data[i]),
          );
        },
      ),
    );
  }
}

class JobApplicationCard extends StatelessWidget {
  final JobApplicationWithJob item;

  const JobApplicationCard({super.key, required this.item});

  JobApplicationModel get app => item.application;
  JobOffer get job => item.job;

  Color get statusColor {
    if (app.isAccepted) return Colors.green;
    if (app.isRejected) return Colors.red;
    if (app.isViewed) return Colors.blue;
    return Colors.grey;
  }

  String statusText(BuildContext context) {
    if (app.isAccepted) return AppLocalizations.of(context)!.status_accepted;
    if (app.isRejected) return AppLocalizations.of(context)!.status_rejected;
    if (app.isViewed) return AppLocalizations.of(context)!.status_viewed;
    return AppLocalizations.of(context)!.status_applied;
  }

  IconData get jobIcon {
    switch (job.jobTitle) {
      case 'Pharmacist':
        return Icons.work_outline;
      case 'Gerant':
        return Icons.business;
      case 'Physician':
        return Icons.work_outline;
      default:
        return Icons.work_outline;
    }
  }
  
  String formatSalary(BuildContext context, String salary) {
    final value = int.tryParse(salary.replaceAll(',', '').trim());

    if (value == null) return salary;

    late String formattedSalaryValue;
    if (value >= 1000000) {
      formattedSalaryValue = "${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M";
    } else if (value >= 1000) {
      formattedSalaryValue = "${(value / 1000).toStringAsFixed(0)}K";
    } else {
      formattedSalaryValue = "$value";
    }

    return AppLocalizations.of(context)!.salary_per_year(formattedSalaryValue);
  }

  String timeAgo(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return AppLocalizations.of(context)!.time_just_now;
    if (diff.inMinutes < 60) return AppLocalizations.of(context)!.time_min_ago(diff.inMinutes);
    if (diff.inHours < 24) return AppLocalizations.of(context)!.time_hours_ago(diff.inHours);
    if (diff.inDays < 7) return AppLocalizations.of(context)!.time_days_ago(diff.inDays);
    if (diff.inDays < 30) return AppLocalizations.of(context)!.time_weeks_ago((diff.inDays / 7).floor());
    if (diff.inDays < 365) return AppLocalizations.of(context)!.time_months_ago((diff.inDays / 30).floor());
    return AppLocalizations.of(context)!.time_years_ago((diff.inDays / 365).floor());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.greenCeladon.withOpacity(0.15),
                child: Icon(
                  jobIcon,
                  color: AppColors.greenCeladon,
                ),
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
                        fontSize: 15,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

          /// META ROW
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                formatSalary(context, job.salary),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                timeAgo(context, app.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          /// CHAT CTA
          if (item.canChat) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ChatWithRecruiterButton(job: job),
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


class _ChatWithRecruiterButtonState
    extends State<ChatWithRecruiterButton> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChat,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCeladon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.chat_with_recruiter,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
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
      final recruiter =
          await recruiterRepo.getByUid(widget.job.userId);

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
                '${recruiter?.pharmacistFirstName } ${recruiter?.pharmacistLastName}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.open_chat_failed),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.work_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.no_applications_title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.no_applications_subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
