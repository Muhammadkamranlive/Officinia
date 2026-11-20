import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobStatsSection/JobStatsSection.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/PharmacyMapWidget.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicantViewModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobViews.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JbViews/JobViews_Repository.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillVerificationMetaRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:client/Server/Services/LocationService.dart';
  // ← our new file
import 'package:client/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

enum ApplicationStatus { applied, accepted, readyToHire, hired, rejected }

// ─────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────
class RecruiterJobDetailScreen extends StatefulWidget {
  final JobOfferWithRecruiter job;
  const RecruiterJobDetailScreen({super.key, required this.job});

  @override
  State<RecruiterJobDetailScreen> createState() =>
      _RecruiterJobDetailScreenState();
}

class _RecruiterJobDetailScreenState extends State<RecruiterJobDetailScreen> {
  bool loading = true;
  final _viewsRepo  = JobViewsRepository();
  final _jobAppRepo = JobApplicationRepository();
  final _jsRepo     = JobSeekerRepository();

  int  _selectedTab = 0;
  AppUser?            appUser;
  JobApplicationModel? jobApplication;
  JobSeekerModel?      _currentJobSeeker;

  @override
  void initState() { super.initState(); _load();
     _fetchLocation();
   }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    appUser = user;
    final jobId = widget.job.jobOffer.docId!;

    final results = await Future.wait([
      _viewsRepo.getByUid(user.userId, jobId),
      if (user.role == UserRole.jobSeeker)
        _jobAppRepo.getJobApplicationForJobSeeker(user.userId, jobId),
      if (user.role == UserRole.jobSeeker)
        _jsRepo.getByUid(user.userId),
    ]);

    if (results[0] == null) {
      await _viewsRepo.add(JobViewsModel(
          userId: user.userId, jobId: jobId,
          counter: 1, createdAt: DateTime.now()));
    }

    if (user.role == UserRole.jobSeeker) {
      jobApplication    = results.length > 1 ? results[1] as JobApplicationModel? : null;
      _currentJobSeeker = results.length > 2 ? results[2] as JobSeekerModel?      : null;
    }

    setState(() => loading = false);
  }

  Future<void> _applyForJob() async {
    if (jobApplication != null) return;
    final job = widget.job.jobOffer;
    final app = JobApplicationModel(
        jobId: job.docId!, recruiterId: job.userId,
        candidateId: appUser!.userId, createdAt: DateTime.now());
    await _jobAppRepo.add(app);
    final repo = NotificationRepository();
    await repo.add(NotificationModel(
        userId: appUser!.userId, type: 'Job_Application',
        title: 'Your job application is sent',
        description: 'Your application for ${job.jobTitle} is sent to Recruiter',
        payload: {'jobTitle': job.jobTitle},
        targetId: job.docId, targetType: 'localNotification',
        route: AppRoutes.notifications, isRead: false, isSent: false,
        createdAt: DateTime.now()));
    await repo.add(NotificationModel(
        userId: job.userId, type: 'Job_Application',
        title: 'You have a new job applicant',
        description: 'New application for "${job.jobTitle}".',
        payload: {'jobTitle': job.jobTitle},
        targetId: job.docId, targetType: 'localNotification',
        route: AppRoutes.notifications, isRead: false, isSent: false,
        createdAt: DateTime.now()));
    setState(() => jobApplication = app);
  }
  LatLng? _seekerLL;
  Future<void> _fetchLocation() async {
  final pos = await LocationService.getCurrentLocation(context);
  if (pos != null && mounted) {
    setState(() {
      _seekerLL = LatLng(pos.latitude, pos.longitude);
    });
  }
}
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return const SizedBox.shrink();
    final role = auth.user!.role;

    if (loading || appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final size = MediaQuery.of(context).size;
    final double maxW = kIsWeb ? (size.width > 920 ? 860.0 : size.width) : size.width;
    final isRecruiterOwner = appUser!.role == UserRole.recruiter;
    final isJobOwner       = appUser!.userId == widget.job.jobOffer.userId;

    // ── seeker LatLng (null-safe) ──────────────────────────
    LatLng? seekerLL;
    if (_currentJobSeeker != null && _currentJobSeeker!.latitude != 0) {
      seekerLL = LatLng(_currentJobSeeker!.latitude,
                        _currentJobSeeker!.longitude);
    }
    else {
      seekerLL = _seekerLL; // or some default value if you prefer
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: maxW,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                JobBannerSection(companyLogo: widget.job.recruiter.logoUrl!),
                const SizedBox(height: 16),
                _JobMainInfo(job: widget.job.jobOffer),
                const SizedBox(height: 16),
                _JobDescription(job: widget.job.jobOffer),
                const SizedBox(height: 16),

                // ── JOB SEEKER VIEW ──────────────────────────
                if (role == UserRole.jobSeeker) ...[
                  _RecruiterInfoSection(recruiter: widget.job.recruiter),
                  const SizedBox(height: 16),

                  // ── MAP — completely isolated widget ────────
                  if (widget.job.recruiter.latitude != 0)
                    PharmacyMapWidget(
                      pharmacyLL:      LatLng(widget.job.recruiter.latitude,
                                              widget.job.recruiter.longitude),
                      pharmacyName:    widget.job.recruiter.pharmacyName,
                      pharmacyAddress: widget.job.recruiter.streetAddress,
                      pharmacyCity:    widget.job.recruiter.city,
                      pharmacyProvince: widget.job.recruiter.province,
                      seekerLL:        seekerLL,   // null if not set
                    ),

                  const SizedBox(height: 16),
                  _jobSeekerActions(),
                  const SizedBox(height: 32),
                ],

                // ── RECRUITER / OWNER VIEW ───────────────────
                if (isRecruiterOwner && isJobOwner) ...[
                  _RecruiterTabs(selectedIndex: _selectedTab,
                      onChanged: (i) => setState(() => _selectedTab = i)),
                  const SizedBox(height: 16),
                  if (_selectedTab == 0)
                    _RecruiterApplicationsSection(
                      jobId: widget.job.jobOffer.docId!,
                      jobTitle: widget.job.jobOffer.jobTitle,
                    )
                  else
                    JobStatsSection(jobId: widget.job.jobOffer.docId!),
                  const SizedBox(height: 24),
                ] else if (role == UserRole.admin) ...[
                  _RecruiterInfoSection(recruiter: widget.job.recruiter),
                  const SizedBox(height: 32),
                  _RecruiterTabs(selectedIndex: _selectedTab,
                      onChanged: (i) => setState(() => _selectedTab = i)),
                  const SizedBox(height: 16),
                  if (_selectedTab == 0)
                    _RecruiterApplicationsSection(
                      jobId: widget.job.jobOffer.docId!,
                      jobTitle: widget.job.jobOffer.jobTitle,
                    )
                  else
                    JobStatsSection(jobId: widget.job.jobOffer.docId!),
                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _jobSeekerActions() {
    final applied = jobApplication != null;
    final canChat  = jobApplication?.canChat ?? false;

    void snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.greenCeladon, duration: const Duration(seconds: 8),
        showCloseIcon: true, closeIconColor: AppColors.white));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: ElevatedButton(
          onPressed: applied ? null : _applyForJob,
          style: ElevatedButton.styleFrom(
              backgroundColor: applied ? Colors.grey : AppColors.greenCeladon,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text(applied ? AppLocalizations.of(context)!.applied_btn : AppLocalizations.of(context)!.apply_btn,
              style: const TextStyle(fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: () async {
            if (!applied) { snack(AppLocalizations.of(context)!.please_apply_first_chat); return; }
            final auth = context.read<AuthProvider>();
            if (auth.user == null) return;
            final chatId = await ChatService().getOrCreateChat(
                jobApplication!.recruiterId, auth.user!.userId);
            Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
              chatId: chatId, otherUserId: jobApplication!.recruiterId,
              personName: '${widget.job.recruiter.pharmacistFirstName} '
                  '${widget.job.recruiter.pharmacistLastName}')));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: canChat ? AppColors.greenCeladon : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text(AppLocalizations.of(context)!.chat_btn, style: const TextStyle(fontWeight: FontWeight.bold)))),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  REMAINING WIDGETS — all unchanged
// ─────────────────────────────────────────────────────────────

class _RecruiterApplicationsSection extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  const _RecruiterApplicationsSection({required this.jobId, required this.jobTitle});
  @override
  State<_RecruiterApplicationsSection> createState() =>
      _RecruiterApplicationsSectionState();
}

class _RecruiterApplicationsSectionState
    extends State<_RecruiterApplicationsSection> {
  late Future<List<JobApplicantViewModel>> applicantsFuture;
  final _jobAppRepo = JobApplicationRepository();

  @override
  void initState() {
    super.initState();
    applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId);
  }

  String _btnText(BuildContext context, String s) {
    final l10n = AppLocalizations.of(context)!;
    switch (s) {
      case 'applied':  return l10n.accept_btn;
      case 'accepted': return l10n.hire_query_btn;
      case 'hired':    return l10n.hired_btn;
      default:         return l10n.accept_btn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.job_applicants_title,
      child: FutureBuilder<List<JobApplicantViewModel>>(
        future: applicantsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(padding: EdgeInsets.all(16),
                child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Padding(padding: const EdgeInsets.all(16),
                child: Text(l10n.no_applicants_yet_label));
          }
          final list = snap.data!
              .where((e) => e.application.status != 'rejected').toList();

          if (kIsWeb && size.width > 700) {
            final rows = <List<JobApplicantViewModel>>[];
            for (var i = 0; i < list.length; i += 2) {
              rows.add(list.sublist(i, i + 2 > list.length ? list.length : i + 2));
            }
            return Column(children: rows.map((row) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _card(row[0])),
                const SizedBox(width: 12),
                row.length > 1 ? Expanded(child: _card(row[1]))
                               : const Expanded(child: SizedBox.shrink()),
              ],
            )).toList());
          }
          return ListView.builder(shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (_, i) => _card(list[i]));
        },
      ),
    );
  }

  Widget _card(JobApplicantViewModel item) {
    final seeker = item.jobSeeker;
    var app = item.application;
    final l10n = AppLocalizations.of(context)!;
    return RecruiterApplicantCard(
      seeker: seeker, buttonStatus: _btnText(context, app.status),
      onViewProfile: () async {
        if (!app.isViewed && app.status == 'applied') {
          app = app.copyWith(status: 'viewed');
          await _jobAppRepo.update(app.docId!, app);
          setState(() { applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId); });
          await NotificationRepository().add(NotificationModel(
              userId: app.candidateId, type: 'Job_Application',
              title: 'Your application is viewed!',
              description: 'Your application has been viewed by the recruiter.',
              payload: {'jobTitle': widget.jobTitle},
              targetId: app.jobId, targetType: 'localNotification',
              route: AppRoutes.notifications, isRead: false, isSent: false,
              createdAt: DateTime.now()));
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => JobSeekerDetailScreen(seeker: seeker)));
      },
      onAccept: () async {
        if (app.status == 'hired') return;
        if (app.status == 'applied' || app.status == 'viewed') {
          app = app.copyWith(status: 'accepted', allowChat: true);
          await _jobAppRepo.update(app.docId!, app);
          setState(() { applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId); });
          await NotificationRepository().add(NotificationModel(
              userId: app.candidateId, type: 'Job_Application',
              title: 'Your application is accepted!',
              description: 'Your application has been accepted by the recruiter.',
              payload: {'jobTitle': widget.jobTitle},
              targetId: app.jobId, targetType: 'localNotification',
              route: AppRoutes.notifications, isRead: false, isSent: false,
              createdAt: DateTime.now()));
          return;
        }
        if (app.status == 'accepted') {
          final hire = await showDialog<bool>(
            context: context, barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.hire_candidate_title),
              content: Text(l10n.hire_confirm_msg),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.cancel)),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenCeladon),
                  child: Text(l10n.hire_btn, style: const TextStyle(color: AppColors.white))),
              ]));
          if (hire == true) {
            app = app.copyWith(status: 'hired');
            await _jobAppRepo.update(app.docId!, app);
            if (!mounted) return;
            setState(() { applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId); });
            await NotificationRepository().add(NotificationModel(
                userId: app.candidateId, type: 'Job_Application',
                title: 'You are Hired!',
                description: 'Congratulations! You have been hired.',
                payload: {'jobTitle': widget.jobTitle},
                targetId: app.jobId, targetType: 'localNotification',
                route: AppRoutes.notifications, isRead: false, isSent: false,
                createdAt: DateTime.now()));
          }
        }
      },
      onReject: () async {
        if (app.status == 'hired') return;
        final ok = await showDialog<bool>(
          context: context, barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.reject_applicant_title),
            content: Text(l10n.reject_confirm_msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.reject_btn, style: const TextStyle(color: AppColors.white))),
            ]));
        if (ok != true) return;
        app = app.copyWith(status: 'rejected', allowChat: false);
        await _jobAppRepo.update(app.docId!, app);
        setState(() { applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId); });
        await NotificationRepository().add(NotificationModel(
            userId: app.candidateId, type: 'Job_Application',
            title: 'Your Application was Rejected',
            description: 'Your application has been rejected.',
            payload: {'jobTitle': widget.jobTitle},
            targetId: app.jobId, targetType: 'localNotification',
            route: AppRoutes.notifications, isRead: false, isSent: false,
            createdAt: DateTime.now()));
      },
    );
  }
}

class RecruiterApplicantCard extends StatefulWidget {
  final JobSeekerModel seeker;
  final VoidCallback onViewProfile, onAccept, onReject;
  final String buttonStatus;
  const RecruiterApplicantCard({super.key, required this.seeker,
      required this.onViewProfile, required this.onAccept,
      required this.onReject, required this.buttonStatus});
  @override
  State<RecruiterApplicantCard> createState() => _RecruiterApplicantCardState();
}

class _RecruiterApplicantCardState extends State<RecruiterApplicantCard> {
  int _verified = 0;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final c = await SkillMetaRepository().getVerifiedSkillCount(widget.seeker.userId);
    if (mounted) setState(() => _verified = c);
  }
  @override
  Widget build(BuildContext context) {
    final isHired = widget.buttonStatus == 'hired';
    return Container(
      margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppColors.greenCeladon,
              child: const Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.seeker.isNameVisible
                ? '${widget.seeker.firstName} ${widget.seeker.lastName}'
                : AppLocalizations.of(context)!.anonymous_candidate,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(widget.seeker.desiredPosition,
                style: const TextStyle(fontSize: 13, color: AppColors.darkGreen)),
          ])),
          if (_verified > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.verified, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(AppLocalizations.of(context)!.verified_count_label(_verified),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ])),
        ]),
        if (widget.seeker.experienceDetails != null) ...[
          const SizedBox(height: 12),
          Text(widget.seeker.experienceDetails!, maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
        ],
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max, children: [
          Expanded(child: OutlinedButton(onPressed: widget.onViewProfile,
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
              child: Text(AppLocalizations.of(context)!.view))),
          const SizedBox(width: 4),
          Expanded(child: ElevatedButton(
              onPressed: isHired ? null : widget.onAccept,
              style: ElevatedButton.styleFrom(
                  backgroundColor: isHired ? Colors.grey : AppColors.greenCeladon,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text(widget.buttonStatus,
                  style: const TextStyle(color: Colors.white)))),
          IconButton(onPressed: isHired ? null : widget.onReject,
              icon: const Icon(Icons.close, color: Colors.red), tooltip: 'Reject'),
        ]),
      ]),
    );
  }
}

class PremiumSkillChip extends StatefulWidget {
  final String skill, status;
  const PremiumSkillChip({super.key, required this.skill, required this.status});
  @override
  State<PremiumSkillChip> createState() => _PremiumSkillChipState();
}

class _PremiumSkillChipState extends State<PremiumSkillChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _a;
  @override
  void initState() { super.initState(); _a = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1200))..repeat(reverse: true); }
  @override
  void dispose() { _a.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final s = _chip(widget.status);
    return Tooltip(message: widget.skill,
      child: AnimatedBuilder(animation: _a, builder: (_, __) {
        final glow = widget.status == 'Verified' ? 0.25 + _a.value * 0.25 : 0.0;
        return Container(
          constraints: const BoxConstraints(maxWidth: 170),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(gradient: s.grad,
            borderRadius: BorderRadius.circular(20), border: Border.all(color: s.border),
            boxShadow: [if (widget.status == 'Verified')
              BoxShadow(color: s.icon.withOpacity(glow), blurRadius: 8, spreadRadius: 0.5)]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(widget.skill, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500))),
            if (s.ico != null) ...[const SizedBox(width: 6), Icon(s.ico, size: 13, color: s.icon)],
          ]));
      }));
  }
}

class _CS { final Gradient grad; final Color border, icon; final IconData? ico;
  _CS({required this.grad, required this.border, required this.icon, this.ico}); }
_CS _chip(String s) {
  switch (s) {
    case 'Verified': return _CS(grad: const LinearGradient(colors: [Color(0xFFE6F6F2), Color(0xFFD1FAE5)]),
      border: const Color(0xFF10B981), icon: const Color(0xFF059669), ico: Icons.verified);
    case 'Pending':  return _CS(grad: const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFED7AA)]),
      border: const Color(0xFFF59E0B), icon: const Color(0xFFD97706), ico: Icons.hourglass_bottom);
    case 'Rejected': return _CS(grad: const LinearGradient(colors: [Color(0xFFFEF2F2), Color(0xFFFECACA)]),
      border: const Color(0xFFEF4444), icon: const Color(0xFFDC2626), ico: Icons.cancel);
    default:         return _CS(grad: const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
      border: const Color(0xFFE2E8F0), icon: Colors.grey);
  }
}

class _RecruiterTabs extends StatelessWidget {
  final int selectedIndex; final ValueChanged<int> onChanged;
  const _RecruiterTabs({required this.selectedIndex, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppUI.card, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        _T(AppLocalizations.of(context)!.applicants_tab, selectedIndex == 0, () => onChanged(0)),
        _T(AppLocalizations.of(context)!.stats_tab,      selectedIndex == 1, () => onChanged(1)),
      ])));
}

class _T extends StatelessWidget {
  final String text; final bool active; final VoidCallback onTap;
  const _T(this.text, this.active, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: active ? AppColors.greenCeladon : Colors.transparent,
          borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600,
          color: active ? Colors.white : AppUI.textSecondary))))));
}

class JobBannerSection extends StatelessWidget {
  final String? bannerImage, companyLogo;
  const JobBannerSection({super.key, this.bannerImage, this.companyLogo});
  bool get _has => bannerImage != null && bannerImage!.isNotEmpty;
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
    Container(height: 180, decoration: BoxDecoration(
        gradient: _has ? null : AppColors.gradientgreen,
        image: _has ? DecorationImage(image: _img(bannerImage!), fit: BoxFit.cover) : null)),
    Container(height: 180, color: Colors.black.withOpacity(.15)),
    Positioned(top: 40, left: 16, child: GestureDetector(onTap: () => Navigator.pop(context),
        child: Container(padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: Colors.black)))),
    Positioned(bottom: -30, left: 16, child: _CompanyLogo(logo: companyLogo)),
  ]);
  ImageProvider _img(String p) =>
      p.startsWith('https') ? NetworkImage(p) : const AssetImage('assets/avatar.png');
}

class _RecruiterInfoSection extends StatelessWidget {
  final Recruiter recruiter;
  const _RecruiterInfoSection({required this.recruiter});
  @override
  Widget build(BuildContext context) => _SectionCard(title: AppLocalizations.of(context)!.recruiter_info_title,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _r(Icons.person, '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}'),
      _r(Icons.work_rounded,           recruiter.pharmacyName),
      _r(Icons.location_city,          recruiter.city),
      _r(Icons.location_city_sharp,    recruiter.province),
      _r(Icons.location_on,            recruiter.streetAddress),
    ]));
  Widget _r(IconData icon, String? v) {
    if (v == null || v.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.greenCeladon), const SizedBox(width: 10),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
      ]));
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? logo;
  const _CompanyLogo({this.logo});
  bool get _has => logo != null && logo!.isNotEmpty;
  @override
  Widget build(BuildContext context) => Container(height: 70, width: 70,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 10)]),
    child: _has
        ? ClipRRect(borderRadius: BorderRadius.circular(12),
            child: Image(image: _img(logo!), fit: BoxFit.contain))
        : const Icon(Icons.work_outlined, size: 32, color: Colors.green));
  ImageProvider _img(String p) => p.startsWith('http') ? NetworkImage(p) : AssetImage(p);
}

class _InfoChip extends StatelessWidget {
  final String label; final IconData icon; final Color? color;
  const _InfoChip(this.label, this.icon, {this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppUI.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: c.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: c), const SizedBox(width: 6),
        Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      ]));
  }
}

class _JobDescription extends StatelessWidget {
  final JobOffer job;
  const _JobDescription({required this.job});
  @override
  Widget build(BuildContext context) {
    if (job.skills.isEmpty) return const SizedBox.shrink();
    return _SectionCard(title: AppLocalizations.of(context)!.required_skills_title,
      child: SizedBox(width: double.infinity,
        child: Wrap(spacing: 6, runSpacing: 6,
            children: job.skills.map((s) => _SkillChip(s)).toList())));
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);
  static const Map<String, IconData> _icons = {
    'Order reception and invoice entry': Icons.receipt_long,
    'Counter customer consultation': Icons.support_agent,
    'Chifa system proficiency': Icons.computer,
    'Stock management': Icons.inventory_2,
    'Physical inventory': Icons.fact_check,
    'Medication ordering and tracking': Icons.medication,
    'Compounding preparations': Icons.science,
    'Overall pharmacy management': Icons.work_rounded,
  };
  @override
  Widget build(BuildContext context) {
    final icon = _icons[label] ?? Icons.star_outline;
    return LayoutBuilder(builder: (_, c) => ConstrainedBox(
      constraints: BoxConstraints(maxWidth: c.maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.greenCeladon.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.greenCeladon.withOpacity(.25))),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Icon(icon, size: 18, color: AppColors.greenCeladon), const SizedBox(width: 8),
          Expanded(child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
              softWrap: false, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ]))));
  }
}

class _JobMainInfo extends StatelessWidget {
  final JobOffer job;
  const _JobMainInfo({required this.job});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 32),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(job.jobTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
      const SizedBox(height: 12),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Wrap(spacing: 10, children: [
          _InfoChip(job.jobType, Icons.work_outline),
          _InfoChip(
            job.isActive ? AppLocalizations.of(context)!.job_open_label : AppLocalizations.of(context)!.job_closed_label, 
            Icons.check_circle,
            color: job.isActive ? Colors.green : Colors.orange),
        ])),
    ]);
}

class _SectionCard extends StatelessWidget {
  final String title; final Widget child;
  const _SectionCard({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04),
            blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      child,
    ]));
}