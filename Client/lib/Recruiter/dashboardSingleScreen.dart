import 'package:client/AdminPannel/MyReportedIssuesScreen.dart';
import 'package:client/AdminPannel/ReportIssueScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Payment/RecruiterPaymentScreen.dart';
import 'package:client/Profile/DeleteAccountScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/PendingRequestsSkillverification.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:client/Server/Services/RecruiterDashboardService.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/widgets/DashboardShimmer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/Widgets/LanguageSelector.dart';
// import 'package:client/Widgets/ThemeSelector.dart';

import '../l10n/app_localizations.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
  final JobOfferRepository jobRepo = JobOfferRepository();
  final repo = SkillVerificationRequestRepository();
  final recruiterRepo = RecruiterRepository();
  List<JobOffer> jobs = [];
  bool loading = false;
  List<SkillVerificationRequest> pendingRequests = [];
  Recruiter? UserModel;
  bool initialLoading = true; // first time only
  bool refreshing = false;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => refreshing = true);
    } else {
      setState(() => initialLoading = true);
    }
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await jobRepo.getByUserId(user.userId);
    final recruiter = await recruiterRepo.getByUid(user.userId);
    final pendingRequest = await repo.getRequestsForRecruiter(user.userId);
    // In _loadProfile(), add these two lines alongside the existing fetches:
    final notificationRepo = NotificationRepository();
    final notifications = await notificationRepo.getByUserId(user.userId);

    setState(() {
      jobs = profile;
      UserModel = recruiter!;
      pendingRequests = pendingRequest;
      initialLoading = false;
      refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (initialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: DashboardShimmer(),
      );
    } else {
      return Scaffold(
        drawer: ProfileDrawer(recruiterUser: UserModel!),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ FIXED HEADER (NOT SCROLLING)
              StreamBuilder<List<NotificationModel>>(
                stream: NotificationRepository().streamByUserId(context.read<AuthProvider>().user!.userId),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
                  return DashboardHeader(
                    profile: UserModel,
                    unreadCount: unreadCount,
                    onNotificationTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  );
                }
              ),

              // ✅ SCROLLABLE CONTENT
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadProfile(isRefresh: true),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        DailyProgressCard(jobs: jobs, loading: loading),
                        const SizedBox(height: 24),
                        ProjectOverviewSection(jobs: jobs),
                        const SizedBox(height: 24),
                        const TodayTaskSection(),
                        const SizedBox(height: 24),
                        SkillVerificationPendingCard(
                          pendingCount: pendingRequests
                              .length, // 🔁 replace with real Firestore count

                          loading: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PendingSkillVerificationScreen(),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 24),
                        TaskDetailsSection(jobs: jobs, laoding: loading),
                        // SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class DashboardHeader extends StatelessWidget {
  final Recruiter? profile;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.profile,
    required this.unreadCount,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: AppColors.darkGreen),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.hi_user(
                    "${profile?.pharmacistFirstName ?? ''} ${profile?.pharmacistLastName ?? ''}",
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Image.asset('assets/logo.png', width: 18, height: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        profile?.pharmacyName ?? "—",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile?.province ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.darkGreen,
                  ),
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
                        color: AppColors.green,
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

class ProfileDrawer extends StatelessWidget {
  final Recruiter recruiterUser;
  const ProfileDrawer({super.key, required this.recruiterUser});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //  PREMIUM HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientgreen1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child:
                          recruiterUser.logoUrl != null &&
                              recruiterUser.logoUrl!.isNotEmpty
                          ? Image.network(
                              recruiterUser.logoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    AppLocalizations.of(context)!.my_account,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    recruiterUser.pharmacyName,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //⚙️ MANAGE Payments
                    _drawerAction(
                      context,
                      icon: Icons.work_outline,
                      title: AppLocalizations.of(context)!.post_job,
                      subtitle: AppLocalizations.of(context)!.post_job_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecruiterPaymentScreen(),
                          ),
                        );
                      },
                    ),
                    //  ⚙️ MANAGE ACCOUNT (CARD STYLE)
                    _drawerAction(
                      context,
                      icon: Icons.settings_outlined,
                      title: AppLocalizations.of(context)!.edit_profile,
                      subtitle: AppLocalizations.of(context)!.edit_profile_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecruiterAccountScreen(
                              mode: AccountFormMode.edit,
                            ),
                          ),
                        );
                      },
                    ),


                    // ⚙️ MANAGE ACCOUNT (CARD STYLE)
                    _drawerAction(
                      context,
                      icon: Icons.bug_report_outlined,
                      title: AppLocalizations.of(context)!.report_issue,
                      subtitle: AppLocalizations.of(context)!.report_issue_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportIssueScreen(
                              mode: ReportIssueMode.create,
                            ),
                          ),
                        );
                      },
                    ),
                    // ⚙️ MANAGE ACCOUNT (CARD STYLE)
                    _drawerAction(
                      context,
                      icon: Icons.report_problem_outlined,
                      title: AppLocalizations.of(context)!.reported_issues,
                      subtitle: AppLocalizations.of(context)!.reported_issues_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyReportedIssuesScreen(
                              isAdminView: false,
                            ),
                          ),
                        );
                      },
                    ),


                    // 🚪 LOGOUT (DESTRUCTIVE)
                    _drawerAction(
                      context,
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)!.logout,
                      subtitle: AppLocalizations.of(context)!.logout_desc,
                      isDestructive: false,
                      onTap: () async {
                        await context.read<AuthProvider>().logout();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                    _drawerAction(
                      context,
                      icon: Icons.delete_forever,
                      title: AppLocalizations.of(context)!.delete_account,
                      subtitle: AppLocalizations.of(context)!.delete_account_desc,
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),

                    const Divider(indent: 20, endIndent: 20),

                    // ✨ LANGUAGE SELECTOR (SECOND WAY)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: AppColors.darkGreen, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.language,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const SizedBox(
                            width: 82,
                            height: 38,
                            child: LanguageSelector(isDashboard: true),
                          ),
                          // const SizedBox(width: 8),
                          // const ThemeSelector(),
                        ],
                      ),
                    ),

                    // 🔻 FOOTER (always visible)
                    const Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 20, top: 10),
                      child: Text(
                        "© 2026 Ophicina",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Premium drawer item
  Widget _drawerAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.darkGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}



class DailyProgressCard extends StatefulWidget {
  final List<JobOffer> jobs;
  final bool loading;

  const DailyProgressCard({
    super.key,
    required this.jobs,
    required this.loading,
  });

  @override
  State<DailyProgressCard> createState() => _DailyProgressCardState();
}

class _DailyProgressCardState extends State<DailyProgressCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    final activeJobs = widget.jobs.where((job) => job.isActive == true).length;
    final totalJobs = widget.jobs.length;

    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: Theme.of(context).brightness == Brightness.light
            ? AppColors.gradientgreen1
            : const LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF2C2C2C)],
              ),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Title ──
          Text(
            AppLocalizations.of(context)!.jobs_status_overview,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // ── Stats & Graph ──
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.jobs_open_count(activeJobs, totalJobs),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.88),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              jobStatusCircle(
                context: context,
                active: activeJobs,
                total: totalJobs,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Action Buttons Row ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.35),
                        width: 0.5,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecruiterAccountScreen(
                          mode: AccountFormMode.edit,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.manage_account,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              // const SizedBox(width: 8),
              // const ThemeSelector(),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: LanguageSelector(isDashboard: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget jobStatusCircle({
  required BuildContext context,
  required int active,
  required int total,
}) {
  final double ratio = total == 0 ? 0 : active / total;

  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: ratio),
    duration: const Duration(milliseconds: 1000),
    curve: Curves.easeOutCubic,
    builder: (_, value, __) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              color: const Color(0xFF97F56C),
              backgroundColor: Colors.white24,
            ),
          ),

          // Center content (counts, not %)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$active/$total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.active,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class ProjectOverviewSection extends StatefulWidget {
  final List<JobOffer> jobs;
  const ProjectOverviewSection({super.key, required this.jobs});

  @override
  State<ProjectOverviewSection> createState() => _ProjectOverviewSectionState();
}

class _ProjectOverviewSectionState extends State<ProjectOverviewSection> {
  @override
  Widget build(BuildContext context) {
    // Replace these with real values from your data source
    final int totalPositions = widget.jobs.length;
    final int filledPositions = widget.jobs
        .where((x) => x.isActive == false)
        .length;
    final int openPositions = totalPositions - filledPositions;
    final int applications = 5;

    final int filledPercent = totalPositions == 0
        ? 0
        : ((filledPositions / totalPositions) * 100).round();

    final int openPercent = totalPositions == 0
        ? 0
        : ((openPositions / totalPositions) * 100).round();

    return Row(
      children: [
        Expanded(
          child: OverviewCard(
            icon: Icons.work_outline,
            title: AppLocalizations.of(context)!.open_jobs,
            subtitle: AppLocalizations.of(context)!.open_jobs_count(openPositions, totalPositions),
            value: "$openPercent%",
            progress: "$openPercent%",
            color: AppColors.gradientOrange,
          ),
        ),

        /// Filled Positions (PERCENTAGE)
        const SizedBox(width: 12),
        Expanded(
          child: OverviewCard(
            icon: Icons.check_circle_outline,
            title: AppLocalizations.of(context)!.filled_positions,
            subtitle: AppLocalizations.of(context)!.filled_positions_count(filledPositions, totalPositions),
            value: "$filledPercent%",
            progress: "$filledPercent%",
            color: AppColors.gradientPink,
          ),
        ),
      ],
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String progress;
  final Gradient color;
  final IconData icon;

  const OverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                progress,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SkillVerificationPendingCard extends StatelessWidget {
  final int pendingCount;
  final int maxExpected; // for progress calculation
  final bool loading;
  final VoidCallback onTap;

  const SkillVerificationPendingCard({
    super.key,
    required this.pendingCount,
    required this.onTap,
    this.maxExpected = 20, // adjust as needed
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: LinearProgressIndicator(),
      );
    }

    final double progress = maxExpected == 0
        ? 0
        : (pendingCount / maxExpected).clamp(0, 1);

    return Container(
      constraints: const BoxConstraints(minHeight: 95), // ✅ ALLOW GROWTH FOR LONG TEXT
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.gradientgreen1,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.darkGreen.withOpacity(0.18)
                : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔹 LEFT INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.skill_verification_requests,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                /// 🔹 MINI PROGRESS BAR (INSTEAD OF CHART)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.pending_requests_count(pendingCount),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// 🔘 ACTION
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.view,
              style: const TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodayTaskSection extends StatefulWidget {
  const TodayTaskSection({super.key});

  @override
  State<TodayTaskSection> createState() => _TodayTaskSectionState();
}

class _TodayTaskSectionState extends State<TodayTaskSection> {
  final bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // ---- Profile Review (unchanged) ----
    final int totalCandidates = 10;
    final int reviewedCandidates = 4;
    final int remainingCandidates = totalCandidates - reviewedCandidates;

    final double reviewProgress = totalCandidates == 0
        ? 0
        : remainingCandidates / totalCandidates;

    final auth = context.read<AuthProvider>();
    final myId = auth.user!.userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(AppLocalizations.of(context)!.hiring_activity),
        const SizedBox(height: 12),

        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= PROFILE REVIEW CARD =================
              Expanded(
                child: FutureBuilder<ProfileReviewStats>(
                  future: RecruiterDashboardService().getProfileReviewStats(
                    myId,
                  ),
                  builder: (context, snapshot) {
                    // -------- LOADING --------
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return TaskCard(
                        title:
                            "${AppLocalizations.of(context)!.review_profiles}\n${AppLocalizations.of(context)!.loading_dots}",
                        progress: 0,
                        icon: Icons.assignment_ind_outlined,
                        color: const Color(0xFF4AA3FF),
                      );
                    }

                    final total = snapshot.data?.totalApplicants ?? 0;
                    final reviewed = snapshot.data?.reviewedApplicants ?? 0;

                    // ✅ Correct progress
                    final double progress = total == 0 ? 0 : reviewed / total;

                    return TaskCard(
                      title:
                          "${AppLocalizations.of(context)!.review_profiles}\n" +
                              AppLocalizations.of(context)!
                                  .reviewed_count(reviewed, total),
                      progress: progress,
                      icon: Icons.assignment_ind_outlined,
                      color: const Color(0xFF4AA3FF),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // ================= CHAT CARD (DYNAMIC) =================
              Expanded(
                child: FutureBuilder<ChatStats>(
                  future: ChatService().getChatStats(myId),
                  builder: (context, snapshot) {
                    // ---------- LOADING STATE ----------
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return TaskCard(
                        title:
                            "${AppLocalizations.of(context)!.chat_card}\n${AppLocalizations.of(context)!.loading_dots}",
                        progress: 0,
                        icon: Icons.chat_bubble_outline,
                        color: const Color(0xFF8E6BFF),
                      );
                    }

                    // ---------- DATA STATE ----------
                    final unreadMessages = snapshot.data?.totalUnread ?? 0;
                    final totalChats = snapshot.data?.totalChats ?? 0;

                    // temporary estimation (same as your logic)
                    final int totalMessages = totalChats == 0 ? 0 : totalChats * 1;

                    final int readMessages = (totalMessages - unreadMessages)
                        .clamp(0, totalMessages);

                    // ✅ FIXED PROGRESS (READ PROGRESS)
                    final double chatProgress = totalMessages == 0 ? 0 : readMessages / totalMessages;

                    return TaskCard(
                      title:
                          "${AppLocalizations.of(context)!.chat_card}\n" +
                              AppLocalizations.of(context)!
                                  .unread_messages_count(unreadMessages),
                      progress: chatProgress,
                      icon: Icons.chat_bubble_outline,
                      color: const Color(0xFF8E6BFF),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 ICON + % ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 TITLE (SAFE)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(), // ⭐ KEY FOR EQUAL HEIGHT
          /// 🔹 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsSection extends StatefulWidget {
  final List<JobOffer> jobs;
  final bool laoding;
  const TaskDetailsSection({
    super.key,
    required this.jobs,
    required this.laoding,
  });

  @override
  State<TaskDetailsSection> createState() => _TaskDetailsSectionState();
}

class _TaskDetailsSectionState extends State<TaskDetailsSection> {
  JobApplicationRepository jobApplicationRepository =
      JobApplicationRepository();
  bool _loading = false;
  List<JobApplicationModel> _profile = []; //store profile
  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await jobApplicationRepository
        .getJobApplicationForRecruiters(user.userId);

    if (!mounted) return;

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || widget.laoding) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    if (widget.jobs.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.no_job_offers_stats,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
    final int totalJobs = widget.jobs.length;
    final int filledJobs = widget.jobs.where((x) => x.isActive == false).length;
    final int openJobs = totalJobs - filledJobs;
    final int candidates = _profile.length;
    final int interviewedCandidates = 2;

    /// SAFE percentages
    final double filledPercent = totalJobs == 0
        ? 0
        : (filledJobs / totalJobs) * 100;

    final double openPercent = totalJobs == 0
        ? 0
        : (openJobs / totalJobs) * 100;

    final double candidatePercent = candidates == 0
        ? 0
        : (interviewedCandidates / candidates) * 100;
    List<PieChartSectionData> sections = [];

    if (filledPercent > 0) {
      sections.add(
        PieChartSectionData(
          value: filledPercent,
          color: AppColors.darkGreen,
          title: "${filledPercent.round()}%",
          radius: 55,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (openPercent > 0) {
      sections.add(
        PieChartSectionData(
          value: openPercent,
          color: AppColors.greenCeladon,
          title: "${openPercent.round()}%",
          radius: 55,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (candidatePercent > 0) {
      sections.add(
        PieChartSectionData(
          value: candidatePercent,
          color: AppColors.lightgreen,
          title: "${candidatePercent.round()}%",
          radius: 55,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.all_time_job_stats,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// 🔵🟠 DONUT CHART
              SizedBox(
                height: 180,
                child: sections.isEmpty
                    ? Center(child: Text(AppLocalizations.of(context)!.no_stats_available))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: sections,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              /// 📌 LEGEND / EXPLANATION (THIS IS CRITICAL)
              _legendItem(
                color: AppColors.darkGreen,
                title: AppLocalizations.of(context)!.filled_positions,
                description: AppLocalizations.of(context)!.filled_positions_count(filledJobs, totalJobs),
              ),
              const SizedBox(height: 8),
              _legendItem(
                color: AppColors.greenCeladon,
                title: AppLocalizations.of(context)!.open_jobs,
                description: AppLocalizations.of(context)!.open_jobs_count(openJobs, totalJobs),
              ),
              const SizedBox(height: 8),
              _legendItem(
                color: AppColors.lightgreen,
                title: AppLocalizations.of(context)!.candidates,
                description: AppLocalizations.of(context)!.candidates_count(_profile.length),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                description,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _title(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class UpcomingTaskSection extends StatelessWidget {
  const UpcomingTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleWithAction(
          AppLocalizations.of(context)!.upcoming_hiring_actions,
          AppLocalizations.of(context)!.see_all,
        ),
        const SizedBox(height: 12),

        _upcomingTaskTile(
          title: AppLocalizations.of(context)!.staff_pharmacist_hiring,
          date: DateTime.now()
              .add(const Duration(days: 2))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),

        _upcomingTaskTile(
          title: AppLocalizations.of(context)!.staff_pharmacist_vacancy,
          date: DateTime.now()
              .add(const Duration(days: 4))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),

        _upcomingTaskTile(
          title: AppLocalizations.of(context)!.staff_pharmacist_opportunity,
          date: DateTime.now()
              .add(const Duration(days: 6))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),
      ],
    );
  }
}

Widget _upcomingTaskTile({
  required String title,
  required String date,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert, color: Colors.grey),
      ],
    ),
  );
}

Widget _titleWithAction(String title, String action) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      Text(
        action,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _title(String text) => Text(
  text,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
);
