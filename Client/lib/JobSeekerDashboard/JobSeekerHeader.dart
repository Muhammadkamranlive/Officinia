import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Widgets/LanguageSelector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class JobSeekerHeader extends StatefulWidget {
  const JobSeekerHeader({super.key});

  @override
  State<JobSeekerHeader> createState() => _JobSeekerHeaderState();
}

class _JobSeekerHeaderState extends State<JobSeekerHeader> {
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  int unreadCount = 0;
  JobSeekerModel? _jobSeeker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobSeeker();
  }

  Future<void> _loadJobSeeker() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await _jobSeekerRepo.getByUid(user.userId);
    final notificationList = await _notificationRepository.getByUserId(
      user.userId,
    );

    if (mounted) {
      setState(() {
        _jobSeeker = result;
        unreadCount = notificationList.where((x) => !x.isRead).length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          /// Menu icon
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 12),

          /// Profile avatar + Name + Position
          _isLoading
              ? const CircularProgressIndicator()
              : Row(
                  children: [
                    // CircleAvatar(
                    //   radius: 28,
                    //   backgroundColor: AppColors.greenCeladon,
                    //   backgroundImage: _jobSeeker?.logoUrl != null
                    //       ? NetworkImage(_jobSeeker!.logoUrl!)
                    //       : null,
                    //   child: _jobSeeker?.logoUrl == null
                    //       ? const Icon(Icons.person, size: 30)
                    //       : null,
                    // ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisplayName(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkGreen,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          _jobSeeker?.desiredPosition ?? AppLocalizations.of(context)!.candidate_label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          const Spacer(),

          /// 🌐 Language Selector
          const SizedBox(
            width: 82,
            height: 38,
            child: LanguageSelector(isDashboard: true),
          ),

          const SizedBox(width: 12),

          /// 🔔 Notification icon with count badge
          GestureDetector(
            onTap: ()  {
               _loadJobSeeker();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkGreen),
                  ),
                  child: const Icon(Icons.notifications),
                ),

                /// 🔴 COUNT BADGE
                if (unreadCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  /// Handles name visibility
  String _getDisplayName() {
    final l10n = AppLocalizations.of(context)!;
    if (_jobSeeker == null) return l10n.candidate_label;
    if (!_jobSeeker!.isNameVisible) return l10n.anonymous_candidate;
    return "${_jobSeeker!.firstName} ${_jobSeeker!.lastName}";
  }
}
