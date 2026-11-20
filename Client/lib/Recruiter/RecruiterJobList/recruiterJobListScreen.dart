import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Recruiter/dashboardSingleScreen.dart';

import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/widgets/JobListShimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/l10n/app_localizations.dart';

class RecruiterJobListScreen extends StatefulWidget {
  const RecruiterJobListScreen({super.key});

  @override
  State<RecruiterJobListScreen> createState() => _RecruiterJobListScreenState();
}

class _RecruiterJobListScreenState extends State<RecruiterJobListScreen>
    with SingleTickerProviderStateMixin {
  final _repo = JobSearchRepository();
  final recruiterRepo = RecruiterRepository();
  bool loading = true;
  bool refreshing = false; // for pull-to-refresh
  List<JobOfferWithRecruiter> jobs = [];
  late TabController _tabController;
  Recruiter? recruiterUser;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reloadJobs();
  }

  Future<void> _reloadJobs({bool isRefresh = false}) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (isRefresh) {
    setState(() => refreshing = true);
  } else {
    setState(() => loading = true);
  }
    jobs = await _repo.getAllJobsWithRecruiters(user.userId);
    final recruiter = await recruiterRepo.getByUid(user.userId);
    setState(() {
      recruiterUser = recruiter!;
       loading      = false;
       refreshing   = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Separate open and closed jobs
    final openJobs = jobs.where((job) => job.jobOffer.isActive).toList();
    final closedJobs = jobs.where((job) => !job.jobOffer.isActive).toList();
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: JobListShimmer(),
      );
    }
    return Scaffold(
      drawer: ProfileDrawer(recruiterUser: recruiterUser!),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const DashboardHeader(),
            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.greenCeladon,
              labelColor: AppColors.greenCeladon,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.open_jobs),
                Tab(text: AppLocalizations.of(context)!.closed_jobs),
              ],
            ),

            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Open Jobs
                  loading
                      ? const JobListShimmer()
                      : RefreshIndicator(
                          onRefresh: () => _reloadJobs(isRefresh: true),
                          child: openJobs.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.of(context).size.height -
                                            200,
                                      ),
                                      child: _EmptyState(),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    24,
                                    16,
                                    16,
                                  ),
                                  itemCount: openJobs.length,
                                  itemBuilder: (_, i) => _JobCard(
                                    job: openJobs[i],
                                    buttonText: AppLocalizations.of(context)!.view_details,
                                  ),
                                ),
                        ),

                  // Closed Jobs
                  loading
                      ? const JobListShimmer()
                      : RefreshIndicator(
                          onRefresh: () => _reloadJobs(isRefresh: true),
                          child: closedJobs.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.of(context).size.height -
                                            200,
                                      ),
                                      child: _EmptyState(),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    24,
                                    16,
                                    16,
                                  ),
                                  itemCount: closedJobs.length,
                                  itemBuilder: (_, i) => _JobCard(
                                    job: closedJobs[i],
                                    buttonText: AppLocalizations.of(context)!.view_details,
                                  ),
                                ),
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

class _JobCard extends StatelessWidget {
  final JobOfferWithRecruiter job;
  final String buttonText;

  const _JobCard({required this.job, required this.buttonText});

  Future<void> _deleteJob(BuildContext context) async {
    final shouldDelete = await _confirmDeleteJob(context);
    if (!shouldDelete) return;

    final jobAppRepo = JobOfferRepository();

    // 2️⃣ Delete the job itself
    await jobAppRepo.delete(job.jobOffer.docId!);

    // 3️⃣ Refresh recruiter job list
    context
        .findAncestorStateOfType<_RecruiterJobListScreenState>()
        ?._reloadJobs(isRefresh: true);
  }

  Future<void> _CloseJobJob(BuildContext context) async {
    final shouldDelete = await _confirmCloseJob(context);
    if (!shouldDelete) return;

    final jobAppRepo = JobOfferRepository();

    // 2️⃣ update status to close it
    JobOfferWithRecruiter updatedJob = JobOfferWithRecruiter(
      jobOffer: job.jobOffer.copyWith(isActive: false),
      recruiter: job.recruiter,
    );

    await jobAppRepo.update(job.jobOffer.docId!, updatedJob.jobOffer);

    // 3️⃣ Refresh recruiter job list
    context
        .findAncestorStateOfType<_RecruiterJobListScreenState>()
        ?._reloadJobs(isRefresh: true);
  }

  static const Map<String, IconData> jobTitleIcons = {
    "Gerant": Icons.business,
    "Pharmacist": Icons.local_pharmacy,
    "Physician": Icons.medical_services,
    "Senior Salesperson": Icons.person_outline,
    "Sales Specialist": Icons.person_add,
    "Intern (Training / Future Recruitment)": Icons.school,
    "Labeling Specialist": Icons.label,
    "Data Entry Specialist": Icons.keyboard,
    "Stock Management Specialist": Icons.inventory,
  };

  String formatSalary(BuildContext context, String salary) {
    final value = int.tryParse(salary.replaceAll(',', '').trim());

    if (value == null) return salary;
    final l10n = AppLocalizations.of(context)!;

    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}${l10n.m_per_year}";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}${l10n.k_per_year}";
    }

    return "$value${l10n.per_year}";
  }

  String timeAgo(BuildContext context, DateTime date) {
    final diff = DateTime.now().difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (diff.inMinutes < 1) return l10n.just_now;
    if (diff.inMinutes < 60) return l10n.min_ago(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hours_ago(diff.inHours);
    if (diff.inDays < 7) return l10n.days_ago(diff.inDays);
    if (diff.inDays < 30) return l10n.weeks_ago((diff.inDays / 7).floor());
    if (diff.inDays < 365) return l10n.months_ago((diff.inDays / 30).floor());
    return l10n.years_ago((diff.inDays / 365).floor());
  }

  String _getLocalizedJobTitle(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    switch (title.toLowerCase()) {
      case 'pharmacist':
        return l10n.job_title_pharmacist;
      case 'gerant':
        return l10n.job_title_gerant;
      case 'physician':
        return l10n.job_title_physician;
      case 'senior salesperson':
        return l10n.job_title_senior_salesperson;
      case 'sales specialist':
        return l10n.job_title_sales_specialist;
      case 'intern':
      case 'intern (training / future recruitment)':
        return l10n.job_title_intern;
      case 'labeling specialist':
        return l10n.job_title_labeling_specialist;
      case 'data entry specialist':
        return l10n.job_title_data_entry_specialist;
      case 'stock management specialist':
        return l10n.job_title_stock_management_specialist;
      default:
        return title;
    }
  }

  String _getLocalizedJobType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'full-time':
      case 'full time':
        return l10n.job_type_full_time;
      case 'part-time':
      case 'part time':
        return l10n.job_type_part_time;
      case 'replacement':
        return l10n.job_type_replacement;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecruiterJobDetailScreen(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.greenCeladon,
                  child: Icon(Icons.work_outlined, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedJobTitle(context, job.jobTitle),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        job.pharmacyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.more_vert, size: 22),
                  splashRadius: 22,
                  onPressed: () => _openJobActions(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "${AppLocalizations.of(context)!.job_type_label}: ${_getLocalizedJobType(context, job.jobType)}",
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                _StatusChip(
                  label: job.jobOffer.isActive
                      ? AppLocalizations.of(context)!.open_status
                      : AppLocalizations.of(context)!.closed_status,
                  color: job.jobOffer.isActive
                      ? AppColors.greenCeladon
                      : AppColors.pinkO,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenCeladon,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  formatSalary(context, job.salary),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  timeAgo(context, job.createdAt),
                  style: const TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openJobActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BottomActionTile(
                icon: Icons.edit_outlined,
                label: AppLocalizations.of(context)!.edit_job,
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobFormScreen(
                        mode: JobFormMode.edit,
                        jobOffer: job.jobOffer,
                      ),
                    ),
                  );

                  if (updated == true) {
                    context
                        .findAncestorStateOfType<_RecruiterJobListScreenState>()
                        ?._reloadJobs();
                  }
                },
              ),

              _BottomActionTile(
                icon: Icons.delete_outline,
                label: AppLocalizations.of(context)!.delete_job,
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteJob(context);
                },
              ),

              _BottomActionTile(
                icon: Icons.close_outlined,
                label: AppLocalizations.of(context)!.close_job,
                onTap: () async {
                  Navigator.pop(context);
                  await _CloseJobJob(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteJob(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.delete_job_confirm_title),
              content: Text(AppLocalizations.of(context)!.delete_job_confirm_msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    iconColor: AppColors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _confirmCloseJob(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.close_job_confirm_title),
              content: Text(AppLocalizations.of(context)!.close_job_confirm_msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    AppLocalizations.of(context)!.close_job,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _BottomActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _BottomActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppUI.textPrimary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }
}

/// Status Chip
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Analytics Chip
class _AnalyticsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AnalyticsChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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
            AppLocalizations.of(context)!.no_job_offers_yet,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.create_first_job_offer,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// enum JobStatus { draft, published, closed }

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final _repoRecruiter = RecruiterRepository();
  Recruiter? _profile; //store profile
  bool _loading = true;
  // pull-to-refresh

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await _repoRecruiter.getByUid(user.userId);

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
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

          // Info section (TAKES FULL SPACE)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.posted_jobs,
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
                        _profile?.pharmacyName ?? "—",
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
                      _profile?.province ?? '',
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
          const SizedBox(width: 10),
          // Notification (auto right)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
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
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
