// ignore: file_names
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/Drawer/JobSeekerDrawer.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';

import 'package:client/JobSeekerDashboard/SelectRecruiterScreen.dart';
import 'package:client/JobSeekerDashboard/SendRequestForSkillVerification.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Widgets/LanguageSelector.dart';

import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillVerificationMetaRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'package:client/AppColors/AppColors.dart' hide premiumShadow;
import 'package:provider/provider.dart';

class JobSeekDashboardScreen extends StatefulWidget {
  const JobSeekDashboardScreen({super.key});

  @override
  State<JobSeekDashboardScreen> createState() => _JobSeekDashboardScreenState();
}

// Add these state variables at the top of _JobSeekDashboardScreenState class
class _JobSeekDashboardScreenState extends State<JobSeekDashboardScreen> {
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
  final JobApplicationRepository _jobApplicationRepo =
      JobApplicationRepository();
  final ProfileViewsRepository _profileViewsRepo = ProfileViewsRepository();
  final JobOfferRepository _jobOfferRepo = JobOfferRepository();
  final SkillMetaRepository _skillMetaRepo =
      SkillMetaRepository(); // ✅ ADD THIS

  JobSeekerModel? _jobSeeker;
  List<JobApplicationWithJob> _applications = [];
  int _totalViews = 0;
  bool _isLoading = true;
  List<JobOffer> _matchingJobs = [];

  // ✅ ADD THESE NEW STATE VARIABLES
  int _verifiedSkillCount = 0;
  Map<String, String> _skillsWithStatus = {};
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    // Load JobSeeker
    final seeker = await _jobSeekerRepo.getByUid(user.userId);

    // ✅ NEW: Load verified skill count
    int verifiedCount = 0;
    Map<String, String> skillsStatus = {};

    if (seeker != null) {
      verifiedCount = await _skillMetaRepo.getVerifiedSkillCount(seeker.userId);

      // ✅ NEW: Load all skill statuses
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(
        seeker.userId,
      );
      for (var skill in seeker.skills) {
        final meta = skillMetas.firstWhere(
          (m) => m.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: seeker.userId,
            skill: skill,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        skillsStatus[skill] = meta.status;
      }
    }

    // Get matching jobs
    final matchingJobs = seeker != null
        ? await _jobOfferRepo.getMatchingJobs(seeker)
        : <JobOffer>[];

    // Load applications with jobs
    final applications = await _jobApplicationRepo
        .getApplicationsWithJobsForCandidate(user.userId);

    // Load total profile views
    final totalViews = await _profileViewsRepo.getTotalViews(user.userId);

    if (!mounted) return;

    setState(() {
      _jobSeeker = seeker;
      _applications = applications;
      _totalViews = totalViews;

      _matchingJobs = matchingJobs;
      _verifiedSkillCount = verifiedCount; // ✅ NEW
      _skillsWithStatus = skillsStatus; // ✅ NEW
      _isLoading = false;
    });
  }

  // ✅ FIXED: Profile card with async verified count
  Widget _profileCard() {
    final seeker = _jobSeeker!;
    final l10n = AppLocalizations.of(context)!;
    final experience = seeker.experienceDetails ?? l10n.na_value;

    // ✅ FIXED: Use state variable instead of seeker.verifiedSkillCount
    final profileStrength =
        _verifiedSkillCount /
        (seeker.skills.isEmpty ? 1 : seeker.skills.length);

    final rank = "#${_applications.length}";
    final matches = _matchingJobs.length.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientgreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      seeker.logoUrl != null && seeker.logoUrl != ""
                      ? NetworkImage(seeker.logoUrl!)
                      : null,
                  child: (seeker.logoUrl == null || seeker.logoUrl == "")
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.darkGreen,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seeker.isNameVisible
                            ? "${seeker.firstName} ${seeker.lastName}"
                            : l10n.anonymous_candidate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seeker.desiredPosition,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PillButton(
                        text: l10n.edit_profile,
                        backgroundColor: AppColors.white,
                        textColor: AppColors.darkGreen,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const JobSeekerAccountScreen(
                                mode: JobSeekerFormMode.edit,
                              ),
                            ),
                          );
                        },
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

            const SizedBox(height: 18),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProfileMetric(
                  label: l10n.profile_strength,
                  value: "${(profileStrength * 100).toInt()}%",
                ),
                _ProfileMetric(label: l10n.job_applications_nav, value: rank),
                _ProfileMetric(label: l10n.matches, value: matches),
              ],
            ),

            const SizedBox(height: 16),

            /// PROGRESS
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: profileStrength,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ FIXED: Stats grid with async verified count
  Widget _statsGrid() {
    final seeker = _jobSeeker!;
    final l10n = AppLocalizations.of(context)!;

    // ✅ FIXED: Use state variable instead of seeker.verifiedSkillCount
    final verifiedSkills = "$_verifiedSkillCount / ${seeker.skills.length}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.25,
        children: [
          _BigStatCard(
            title: l10n.job_matches,
            value: _matchingJobs.length.toString(),
            subtitle: l10n.based_on_your_profile,
            icon: Icons.work_outline,
            gradient: AppColors.gradientPink,
          ),
          _BigStatCard(
            title: l10n.skills_verified_count,
            value: verifiedSkills,
            subtitle: l10n.improve_visibility,
            icon: Icons.verified_outlined,
            gradient: AppColors.gradientgreen1,
          ),
          _BigStatCard(
            title: l10n.profile_views_count,
            value: _totalViews.toString(),
            subtitle: l10n.recruiters_viewed_you,
            icon: Icons.visibility_outlined,
            gradient: calmBlueGradient,
          ),
          _BigStatCard(
            title: l10n.profile_visibility,
            value: seeker.isNameVisible ? l10n.visibility_high : l10n.visibility_anonymous,
            subtitle: l10n.privacy_mode,
            icon: seeker.isNameVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            gradient: calmGreenGradient,
          ),
        ],
      ),
    );
  }

  /// ✅ FIXED: Skills section with async data
  Widget _skillsSection() {
    final seeker = _jobSeeker!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.skill_verification_title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),

          GradientActionCard(
  title: l10n.verify_your_skills,
  subtitle: l10n.verify_skills_desc,
  icon: Icons.how_to_reg_rounded, // person + checkmark = someone vouching for you
  gradient: [
    AppColors.greenCeladon,
    AppColors.greenCeladon.withOpacity(0.85),
  ],
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectRecruiterScreen(),
      ),
    );
  },
),

          // const SizedBox(height: 14),

          // GradientActionCard(
          //   title: "Job-Based Verification",
          //   subtitle: "Verify skills through a completed job on the platform",
          //   icon: Icons.work_outline_rounded,
          //   gradient: const [Color(0xFFFACC15), Color(0xFFF59E0B)],
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) => const SendSkillVerificationRequestScreen(),
          //       ),
          //     );
          //   },
          // ),
          const SizedBox(height: 12),

          // ✅ FIXED: Use _skillsWithStatus instead of seeker.skills.entries
          ..._skillsWithStatus.entries.map((e) {
            Color color;
            String statusText;
            if (e.value == 'Verified') {
              color = Colors.green;
              statusText = l10n.status_verified_label;
            } else if (e.value == 'Pending') {
              color = Colors.orange;
              statusText = l10n.status_pending_label;
            } else {
              color = Colors.red;
              statusText = l10n.status_rejected_label;
            }
            return _skillRow(e.key, e.value, statusText, color);
          }).toList(),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(232, 245, 233, 1),
      drawer: JobSeekerDrawer(recruiterUser: _jobSeeker!),
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ HEADER
            StreamBuilder<List<NotificationModel>>(
              stream: NotificationRepository().streamByUserId(context.read<AuthProvider>().user!.userId),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
                return JobSeekerHeader(
                  jobSeeker: _jobSeeker,
                  unreadCount: unreadCount,
                  onNotificationTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                );
              }
            ),

            /// ✅ CONTENT
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    children: [
                      _profileCard(),
                      const SizedBox(height: 24),
                      _statsGrid(),
                      const SizedBox(height: 24),
                      _skillsSection(),
                      const SizedBox(height: 24),
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

class JobSeekerHeader extends StatelessWidget {
  final JobSeekerModel? jobSeeker;
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const JobSeekerHeader({
    super.key,
    required this.jobSeeker,
    required this.unreadCount,
    required this.onNotificationTap,
  });

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
          Row(
            children: [
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobSeeker != null && jobSeeker!.isNameVisible
                        ? "${jobSeeker!.firstName} ${jobSeeker!.lastName}"
                        : AppLocalizations.of(context)!.anonymous_candidate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    jobSeeker?.desiredPosition ?? AppLocalizations.of(context)!.candidate_label,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          /// 🔔 Notification icon with count badge
          GestureDetector(
            onTap: () {
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
}

class GradientActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const GradientActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title, value, subtitle;
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
    return Container(
      padding: const EdgeInsets.all(16), // ⬅ slightly reduced
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: premiumShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ KEY
        children: [
          Icon(icon, color: Colors.white, size: 24),

          Column(
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22, // ⬅ reduced from 26
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _skillRow(String title, String rawStatus, String localizedStatus, Color color) {
  IconData statusIcon = rawStatus.contains("Auth")
      ? Icons.check_circle
      : rawStatus == "Pending"
      ? Icons.hourglass_top
      : Icons.check_circle;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: premiumShadow,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(
          localizedStatus,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class PillButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const PillButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}





// Widget jobSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Text(
//           "Featured Jobs",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       const SizedBox(height: 12),

//       /// 🔑 IMPORTANT: give height
//       SizedBox(
//         height: 230, // 🔑 slightly taller than card
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
//           scrollDirection: Axis.horizontal,
//           itemCount: jobData.length,
//           separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
//           itemBuilder: (context, index) {
//             return SizedBox(
//               width: 320, // 🔑 card width for premium feel
//               child: FeaturedJobCard(),
//             );
//           },
//         ),
//       ),

//       const SizedBox(height: 24),

//       const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Text(
//           "Job Matches",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),

//       const SizedBox(height: 12),

//       /// 🔑 IMPORTANT: give height
//       SizedBox(
//         height: 230, // 🔑 slightly taller than card
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
//           scrollDirection: Axis.horizontal,
//           itemCount: jobData.length,
//           separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
//           itemBuilder: (context, index) {
//             return SizedBox(
//               width: 320, // 🔑 card width for premium feel
//               child: JobCard(
//                 title: jobData[index].title,
//                 company: jobData[index].company,
//                 type: jobData[index].type,
//                 salary: jobData[index].salary,
//                 icon: jobData[index].icon,
//                 buttonText: jobData[index].button,
//               ),
//             );
//           },
//         ),
//       ),

//       const SizedBox(height: 12),
//     ],
//   );
// }

// class FeaturedJobCard extends StatelessWidget {
//   const FeaturedJobCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.greenCeladon,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: premiumShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TOP
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               CircleAvatar(
//                 backgroundColor: Colors.white24,
//                 child: Icon(Icons.local_hospital, color: Colors.white),
//               ),
//               Icon(Icons.bookmark_border, color: Colors.white),
//             ],
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             "Job Seeker",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//           const Text(
//             "Health First Pharmacy",
//             style: TextStyle(color: Colors.white70),
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             "Part-time / Remote",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//           ),

//           const SizedBox(height: 16),

//           /// ACTION
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _pillButton("Apply Now", Colors.white, Colors.black),
//               const Text(
//                 "150K / year",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class JobCard extends StatelessWidget {
//   final String title;
//   final String company;
//   final String type;
//   final String salary;
//   final IconData icon;
//   final String buttonText;

//   const JobCard({
//     required this.title,
//     required this.company,
//     required this.type,
//     required this.salary,
//     required this.icon,
//     required this.buttonText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       //margin: const EdgeInsets.symmetric(vertical: 12), // 🔑 space for shadow
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: premiumShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TOP
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CircleAvatar(
//                 backgroundColor: AppColors.greenCeladon,
//                 child: Icon(icon, color: Colors.white),
//               ),
//               const Icon(Icons.bookmark_border),
//             ],
//           ),

//           const SizedBox(height: 12),

//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//           ),
//           Text(
//             company,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: Colors.black54),
//           ),

//           const SizedBox(height: 12),

//           Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),

//           const SizedBox(height: 16),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _pillButton(buttonText, AppColors.greenCeladon, Colors.white),
//               Text(salary, style: const TextStyle(fontWeight: FontWeight.w700)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

