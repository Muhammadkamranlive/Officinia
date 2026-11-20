import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/l10n/app_localizations.dart';

class AdminHeader extends StatefulWidget {
  final String Jobtile;
  final String screenName;
  const AdminHeader({super.key,this.Jobtile="",this.screenName=""});

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  final AdminRepository _jobSeekerRepo = AdminRepository();
  final NotificationRepository _notificationRepository =
      NotificationRepository();
      
  AdminsModel? _jobSeeker;
  bool _isLoading = true;
  int unreadCount = 0;
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

    final result           = await _jobSeekerRepo.getByUid(user.userId);
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
                  
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                         widget.Jobtile==""? _getDisplayName():widget.Jobtile,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: AppColors.darkGreen,fontSize: 19),
                        ),
                        Text(
                          widget.screenName==""? AppLocalizations.of(context)!.admin_dashboard_subtitle:widget.screenName,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),

          const Spacer(),

          /// Notification icon
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
    return "${_jobSeeker!.pharmacistFirstName} ${_jobSeeker!.pharmacistLastName}";
  }
}


class Admin_Header extends StatelessWidget {
  final String jobTitle;
  final String screenName;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const Admin_Header({
    super.key,
    this.jobTitle = "",
    this.screenName = "",
    this.unreadCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                jobTitle.isEmpty ? AppLocalizations.of(context)!.admin_label : jobTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  fontSize: 19,
                ),
              ),
              Text(
                screenName.isEmpty ? AppLocalizations.of(context)!.admin_dashboard_subtitle : screenName,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNotificationTap,
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
}

