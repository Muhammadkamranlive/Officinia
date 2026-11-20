import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/AdminHeader.dart';
import 'package:client/AdminPannel/AdminPaymentsScreen.dart';
import 'package:client/AdminPannel/DashboardActionCards.dart';
import 'package:client/AdminPannel/MyReportedIssuesScreen.dart';

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/Drawer/JobSeekerDrawer.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';

import 'package:client/Server/Enums/AdminEnum.dart' show AdminFormMode;
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/PaymentStatus.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/PaymentRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/Server/Repo/ReportIssueRepository.dart';
import 'package:client/widgets/DashboardShimmer.dart';
import 'package:client/Widgets/LanguageSelector.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final JobOfferRepository jobRepo = JobOfferRepository();
  final RecruiterRepository recruiterRepo = RecruiterRepository();
  final JobApplicationRepository jobApplicationRepo = JobApplicationRepository();
  final JobSeekerRepository jobSeekerRepository = JobSeekerRepository();
  final SkillVerificationRequestRepository skillRepository =
      SkillVerificationRequestRepository();
  final AdminRepository adminRepository = AdminRepository();

  AdminsModel? admin;
  List<JobOffer> jobs = [];
  List<JobOffer> activejobs = [];
  List<Recruiter> recruiters = [];
  List<JobApplicationModel> applications = [];
  List<JobSeekerModel> jobSeekers = [];
  List<SkillVerificationRequest> skillVerifications = [];
  int issueCount = 0;
  bool loading = false;
  final _repo = ReportIssueRepository();
  final _paymentRepo = PaymentRepository();
  final _recruiterRepo = RecruiterRepository();

  bool initialLoading = true;
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

    final NotificationRepository notificationRepository = NotificationRepository();
    final notificationList = await notificationRepository.getByUserId(user.userId);
    final admins = await adminRepository.getByUid(user.userId);
    final profile = await jobRepo.getAll();
    final recruiterList = await recruiterRepo.getAllFromCollection();
    final applicationList = await jobApplicationRepo.getAllFromCollection();
    final jobSeekerList = await jobSeekerRepository.getAllFromCollection();
    final skillVerificationList = await skillRepository.getAllFromCollection();
    final issues = await _repo.getAll();
    await _load();

    setState(() {
      admin = admins!;
      jobs = profile;
      activejobs = profile.where((job) => job.isActive).toList();
      recruiters = recruiterList;
      applications = applicationList;
      jobSeekers = jobSeekerList;
      skillVerifications = skillVerificationList;
      issueCount = issues.length;
      initialLoading = false;
      refreshing = false;
    });
  }

  List<PaymentEntry> _entries = [];

  Future<void> _load() async {
    final payments = await _paymentRepo.getByStatus(PaymentStatus.paid);
    final entries = await Future.wait(
      payments.map((p) async {
        final recruiter = await _recruiterRepo.getByUid(p.recruiterId);
        return PaymentEntry(payment: p, recruiter: recruiter);
      }),
    );
    setState(() {
      _entries = entries;
    });
  }

  double get _totalRevenue =>
      _entries.fold(0, (sum, e) => sum + e.payment.amount);

  int get _activeCount => _entries.where((e) => e.payment.isActive).length;

  @override
  Widget build(BuildContext context) {
    if (initialLoading) {
      return const DashboardShimmer();
    }

    final size = MediaQuery.of(context).size;
    // ✅ Web: cap content at 900px (dashboard benefits from more width than auth screens)
    // Mobile: full width, no change
    final double maxWidth =
        kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;

    return Scaffold(
      drawer: AdminDrawer(admin: admin!),
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              StreamBuilder<List<NotificationModel>>(
                stream: NotificationRepository().streamByUserId(context.read<AuthProvider>().user!.userId),
                builder: (context, snapshot) {
                  final liveUnreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
                  return Admin_Header(
                    jobTitle: admin != null
                        ? "${admin!.pharmacistFirstName} ${admin!.pharmacistLastName}"
                        : "",
                    unreadCount: liveUnreadCount,
                    onNotificationTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                    },
                  );
                }
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadProfile(isRefresh: true),
                  child: SingleChildScrollView(
                    // ✅ Center content on web, full width on mobile
                    child: Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            // ✅ Mobile: original 16px. Web: slightly more breathing room.
                            horizontal: kIsWeb ? 24.0 : 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              DailyProgressCard(jobs: jobs, loading: false),

                              const SizedBox(height: 20),

                              // ✅ On web wide screens: show stat cards in a 4-column row
                              // On mobile: original 2x2 grid — unchanged
                              kIsWeb && size.width > 700
                                  ? _statsCardsWebRow(
                                      context,
                                      recruiters,
                                      jobSeekers,
                                      activejobs,
                                      applications,
                                      skillVerifications,
                                    )
                                  : _statsCards(
                                      context,
                                      recruiters,
                                      jobSeekers,
                                      activejobs,
                                      applications,
                                      skillVerifications,
                                    ),

                              const SizedBox(height: 16),

                              DashboardActionCards(
                                recruiterRequestsCount: recruiters,
                                paymentsCount: _entries,
                              ),

                              const SizedBox(height: 16),

                              // ✅ On web: charts side by side. On mobile: stacked (original).
                              kIsWeb && size.width > 700
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: _jobBarChart(
                                            context,
                                            recruiters,
                                            jobSeekers,
                                            activejobs,
                                            applications,
                                            skillVerifications,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _activityLineChart(
                                            context,
                                            recruiters,
                                            jobSeekers,
                                            activejobs,
                                            applications,
                                            skillVerifications,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _jobBarChart(
                                          context,
                                          recruiters,
                                          jobSeekers,
                                          activejobs,
                                          applications,
                                          skillVerifications,
                                        ),
                                        const SizedBox(height: 16),
                                        _activityLineChart(
                                          context,
                                          recruiters,
                                          jobSeekers,
                                          activejobs,
                                          applications,
                                          skillVerifications,
                                        ),
                                      ],
                                    ),

                              const SizedBox(height: 16),

                              _bottomCards(context, issueCount),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Original 2x2 grid — mobile, completely unchanged
  Widget _statsCards(
    BuildContext context,
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                title: AppLocalizations.of(context)!.admin_active_jobs_title,
                value: activeJobs.length.toString(),
                subtitle: AppLocalizations.of(context)!.admin_active_jobs_sub,
                icon: Icons.work_outline_rounded,
                gradient: AppColors.gradientOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                title: AppLocalizations.of(context)!.admin_skill_req_title,
                value: skillVerifications.length.toString(),
                subtitle: AppLocalizations.of(context)!.admin_skill_req_sub,
                icon: Icons.verified_user_rounded,
                gradient: AppColors.gradientPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                title: AppLocalizations.of(context)!.admin_recruiters_title,
                value: recruiters.length.toString(),
                subtitle: AppLocalizations.of(context)!.admin_recruiters_sub,
                icon: Icons.business_center,
                gradient: AppColors.gradientgreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                title: AppLocalizations.of(context)!.admin_seekers_title,
                value: jobSeekers.length.toString(),
                subtitle: AppLocalizations.of(context)!.admin_seekers_sub,
                icon: Icons.people_alt_rounded,
                gradient: AppColors.gradientgreen1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ Web only: all 4 stat cards in a single row
  Widget _statsCardsWebRow(
    BuildContext context,
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    return Row(
      children: [
        Expanded(
          child: _BigStatCard(
            title: AppLocalizations.of(context)!.admin_active_jobs_title,
            value: activeJobs.length.toString(),
            subtitle: AppLocalizations.of(context)!.admin_active_jobs_sub,
            icon: Icons.work_outline_rounded,
            gradient: AppColors.gradientOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BigStatCard(
            title: AppLocalizations.of(context)!.admin_skill_req_title,
            value: skillVerifications.length.toString(),
            subtitle: AppLocalizations.of(context)!.admin_skill_req_sub,
            icon: Icons.verified_user_rounded,
            gradient: AppColors.gradientPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BigStatCard(
            title: AppLocalizations.of(context)!.admin_recruiters_title,
            value: recruiters.length.toString(),
            subtitle: AppLocalizations.of(context)!.admin_recruiters_sub,
            icon: Icons.business_center,
            gradient: AppColors.gradientgreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BigStatCard(
            title: AppLocalizations.of(context)!.admin_seekers_title,
            value: jobSeekers.length.toString(),
            subtitle: AppLocalizations.of(context)!.admin_seekers_sub,
            icon: Icons.people_alt_rounded,
            gradient: AppColors.gradientgreen1,
          ),
        ),
      ],
    );
  }

  // — chart and card methods completely unchanged below —

  Widget _jobBarChart(
    BuildContext context,
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    final int openJobs = activeJobs.where((j) => j.isActive == true).length;
    final int closedJobs = activeJobs.where((j) => j.isActive == false).length;
    final int skillRequests = skillVerifications.length;

    final maxValue = [openJobs, closedJobs, skillRequests]
        .reduce((a, b) => a > b ? a : b);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: Colors.indigo),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.admin_platform_activity,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.admin_platform_activity_desc,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 5 : maxValue.toDouble() + 2,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxValue <= 5 ? 1 : (maxValue / 4).ceilToDouble(),
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return _xLabel(AppLocalizations.of(context)!.admin_open_jobs);
                          case 1:
                            return _xLabel(AppLocalizations.of(context)!.admin_closed_jobs);
                          case 2:
                            return _xLabel(AppLocalizations.of(context)!.admin_skill_req_title);
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _bar(0, openJobs, [Colors.blue, Colors.blueAccent]),
                  _bar(1, closedJobs, [Colors.grey, Colors.black54]),
                  _bar(2, skillRequests, [Colors.purple, Colors.deepPurpleAccent]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, int value, List<Color> colors) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          width: 18,
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(colors: colors),
        ),
      ],
    );
  }

  Widget _xLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _activityLineChart(
    BuildContext context,
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    final int recruiterCount = recruiters.length;
    final int jobSeekerCount = jobSeekers.length;

    List<FlSpot> _generateTrend(int total) {
      if (total == 0) {
        return const [
          FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0),
        ];
      }
      return [
        FlSpot(0, total * 0.2),
        FlSpot(1, total * 0.4),
        FlSpot(2, total * 0.6),
        FlSpot(3, total * 0.8),
        FlSpot(4, total.toDouble()),
      ];
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, size: 18, color: Colors.indigo),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.admin_user_activity,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.admin_user_activity_desc,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: [recruiterCount, jobSeekerCount]
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() +
                    2,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateTrend(jobSeekerCount),
                    isCurved: true,
                    barWidth: 3,
                    gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.blueAccent]),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(.25),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: _generateTrend(recruiterCount),
                    isCurved: true,
                    barWidth: 3,
                    gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.deepPurpleAccent]),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(.20),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: Colors.blue, label: AppLocalizations.of(context)!.admin_seekers_title),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.purple, label: AppLocalizations.of(context)!.admin_recruiters_title),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomCards(BuildContext context, int issueCount) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const MyReportedIssuesScreen(isAdminView: true),
                ),
              );
            },
            child: _miniCard(
              AppLocalizations.of(context)!.admin_reported_issues,
              issueCount.toString(),
              Icons.error,
              Colors.pink,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminPaymentsScreen(),
                ),
              );
            },
            child: _miniCard(
              AppLocalizations.of(context)!.admin_total_earnings,
              "${_totalRevenue.toStringAsFixed(2)} DZD",
              Icons.attach_money,
              Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniCard(String title, String value, IconData icon, Color color) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumShadow,
      ),
      child: child,
    );
  }
}

// — unchanged widgets below —

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: premiumShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.gradientgreen1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.admin_job_status_overview,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.admin_jobs_open_count(activeJobs, totalJobs),
                  style: const TextStyle(color: AppColors.white),
                ),
                const SizedBox(height: 14),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightgreen,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminAccountScreen(
                                mode: AdminFormMode.edit,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.admin_manage_account,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(
                        height: 38,
                        child: LanguageSelector(isDashboard: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          jobStatusCircle(context, active: activeJobs, total: widget.jobs.length),
        ],
      ),
    );
  }
}

Widget jobStatusCircle(BuildContext context, {required int active, required int total}) {
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
                AppLocalizations.of(context)!.admin_active_label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      );
    },
  );
}