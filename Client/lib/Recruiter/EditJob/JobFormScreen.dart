import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobTypeModel.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';

import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobTypeRepository.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';

import '../../Payment/RecruiterPaymentScreen.dart';
import '../../Server/Repo/Receuiter/RecruiterRepository.dart';

enum JobFormMode { create, edit }

class JobFormScreen extends StatefulWidget {
  final JobFormMode mode;
  final JobOffer? jobOffer;

  const JobFormScreen({super.key, required this.mode, this.jobOffer});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _repo = JobOfferRepository();
  final _repoNotifications = NotificationRepository();
  final _jobOptionRepo = JobOptionRepository();
  final _jobTypeRepo = JobTypeRepository(); // ← replaces hardcoded list
  final _recruiterRepo = RecruiterRepository();
  // ── Current language — swap to real locale when i18n is ready ─
  String get _lang => Localizations.localeOf(context).languageCode;

  // ── Live data from Firestore ───────────────────────────────────
  List<JobOption> _jobTitleOptions = [];
  List<JobOption> _skillOptions = [];
  List<JobTypeModel> _jobTypeOptions = []; // ← was: final jobTypes = [...]
  bool _optionsLoaded = false;

  // ── Form state ─────────────────────────────────────────────────
  final descCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();
  String? jobTitle;
  String? jobType; // stores JobTypeModel.en key
  final Set<String> selectedSkills = {}; // stores JobOption.en key

  bool loading = true;

  bool get isCreate => widget.mode == JobFormMode.create;
  bool get isEdit => widget.mode == JobFormMode.edit;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    descCtrl.dispose();
    salaryCtrl.dispose();
    super.dispose();
  }

  // ── Load all Firestore options in parallel, then pre-fill ──────
  Future<void> _loadAll() async {
    final results = await Future.wait([
      _jobOptionRepo.getJobTitles(), // [0]
      _jobOptionRepo.getSkills(), // [1]
      _jobTypeRepo.getJobTypes(), // [2] ← replaces hardcoded list
    ]);

    setState(() {
      _jobTitleOptions = results[0] as List<JobOption>;
      _skillOptions = results[1] as List<JobOption>;
      _jobTypeOptions = results[2] as List<JobTypeModel>;
      _optionsLoaded = true;
    });

    _prefillJobOffer();
  }

  void _prefillJobOffer() {
    if (widget.jobOffer != null) {
      final job = widget.jobOffer!;
      jobTitle = job.jobTitle;
      jobType = job.jobType; // already stored as EN key
      salaryCtrl.text = job.salary;
      selectedSkills.addAll(job.skills);
    }
    setState(() => loading = false);
  }

  // ── Validation ─────────────────────────────────────────────────
  bool _validateForm() {
    if (jobTitle == null || jobTitle!.isEmpty) {
      _showError(AppLocalizations.of(context)!.please_select_job_title);
      return false;
    }
    if (jobType == null || jobType!.isEmpty) {
      _showError(AppLocalizations.of(context)!.please_select_job_type);
      return false;
    }
    if (selectedSkills.isEmpty) {
      _showError(AppLocalizations.of(context)!.please_add_skill);
      return false;
    }
    return true;
  }

  Future<bool> _checkLicenseStatus(Recruiter recruiter) async {
    
    // 2️⃣ Check license
    if (!recruiter.hasActiveLicense) {
         print(recruiter.licenseStatus);
        _showError(
          AppLocalizations.of(context)!.active_listing_required,
        );
      return false;
    }
    
    // ✅ Everything OK
    return true;
  }

  // ── Save ───────────────────────────────────────────────────────
  Future<void> _saveJob({required bool post}) async {
    
    final authUser = context.read<AuthProvider>().user;
    if (authUser == null) return ;

    final recruiter = await _recruiterRepo.getByUid(authUser.userId);

    if (recruiter == null) {
      _showError(AppLocalizations.of(context)!.recruiter_profile_not_found);
      return ;
    }
    if (!await _checkLicenseStatus(recruiter)) {
      // Redirect to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RecruiterPaymentScreen()),
      );
      return;
    }

   
       // 1. Check & increment atomically
  final allowed = await _recruiterRepo.tryIncrementPostCount(recruiter.docId!);

  if (!allowed) {
    // Show dialog
    showDialog
    (
      context: context,
      builder: (_) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.monthlyLimitTitle),
        content: Text(
          AppLocalizations.of(context)!.monthlyLimitMessage(
             recruiter.jobPostLimit.toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
    return ;
  }

    if (!_validateForm()) return;
    setState(() => loading = true);

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final job = JobOffer(
      docId: widget.jobOffer?.docId,
      userId: user.userId,
      jobTitle: jobTitle ?? '',
      jobType: jobType ?? '', // EN key stored
      skills: selectedSkills.toList(),
      salary: salaryCtrl.text.trim(),
      createdAt: widget.jobOffer?.createdAt ?? DateTime.now(),
      isDraft: !post,
      isActive: post,
    );

    if (isCreate) {
      final jobId = await _repo.add(job);
      await _repoNotifications.add(
        NotificationModel(
          userId: user.userId,
          type: 'job_post',
          title: AppLocalizations.of(context)!.notif_job_posted_title,
          description: AppLocalizations.of(context)!.notif_job_posted_desc(job.jobTitle),
          payload: {'jobTitle': job.jobTitle},
          targetId: jobId,
          targetType: 'job',
          route: AppRoutes.notifications,
          isRead: false,
          isSent: false,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await _repo.update(job.docId!, job);
    }

    setState(() => loading = false);
    Navigator.pop(context);
  }

  // ── Skill selector bottom sheet ────────────────────────────────
  void _openSkillSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * .65,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.select_skills,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _skillOptions.isEmpty
                        ? Center(child: Text(AppLocalizations.of(context)!.no_skills_available))
                        : SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _skillOptions.map((skill) {
                                final label = skill.label(_lang);
                                final selected = selectedSkills.contains(
                                  skill.en,
                                );
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      selected
                                          ? selectedSkills.remove(skill.en)
                                          : selectedSkills.add(skill.en);
                                    });
                                    setState(() {});
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.green.withOpacity(.12)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.green
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: selected
                                            ? AppColors.green
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (loading || !_optionsLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Guard: if stored value no longer exists in Firestore, reset to null
    final validTitles = _jobTitleOptions.map((e) => e.en).toList();
    if (jobTitle != null && !validTitles.contains(jobTitle)) jobTitle = null;

    final validTypes = _jobTypeOptions.map((e) => e.en).toList();
    if (jobType != null && !validTypes.contains(jobType)) jobType = null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isCreate ? AppLocalizations.of(context)!.create_job_offer : AppLocalizations.of(context)!.edit_job_offer),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────
                Text(
                  AppLocalizations.of(context)!.job_details,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.job_details_desc,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),

                const SizedBox(height: 20),
                const _Divider(),
                const SizedBox(height: 20),

                // ── Job Title ──────────────────────────────────────
                _DropdownField(
                  label: AppLocalizations.of(context)!.job_title,
                  value: jobTitle,
                  items: _jobTitleOptions
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.en,
                          child: Text(e.label(_lang)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => jobTitle = v),
                ),

                const SizedBox(height: 16),

                // ── Job Type ───────────────────────────────────────
                _DropdownField(
                  label: AppLocalizations.of(context)!.job_type,
                  value: jobType,
                  items: _jobTypeOptions
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.en,
                          child: Text(e.label(_lang)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => jobType = v),
                ),

                const SizedBox(height: 20),
                const _Divider(),
                const SizedBox(height: 20),

                // ── Skills label ───────────────────────────────────
                Text(
                  AppLocalizations.of(context)!.required_skills,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.required_skills_desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),

                // ── Add skills button ──────────────────────────────
                GestureDetector(
                  onTap: () => _openSkillSelector(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.green, width: 1.5),
                      color: AppColors.green.withOpacity(0.04),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.add_skills,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Skill chips ────────────────────────────────────
                if (selectedSkills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedSkills.map((skillEn) {
                      final match = _skillOptions.firstWhere(
                        (o) => o.en == skillEn,
                        orElse: () => JobOption(
                          type: JobOptionType.skill,
                          order: 0,
                          en: skillEn,
                          fr: skillEn,
                          ar: skillEn,
                          createdAt: DateTime.now(),
                        ),
                      );
                      return Chip(
                        label: Text(match.label(_lang)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => selectedSkills.remove(skillEn)),
                        backgroundColor: AppColors.green.withOpacity(0.08),
                        side: BorderSide(
                          color: AppColors.green.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),
                const _Divider(),
                const SizedBox(height: 24),

                // ── Post button — inside the card ──────────────────
                SizedBox(
                  width: double.infinity,
                  child: _customButton(
                    text: isCreate ? AppLocalizations.of(context)!.post_job_btn : AppLocalizations.of(context)!.update_job_btn,
                    size: MediaQuery.of(context).size,
                    gradient: AppColors.gradientgreen,
                    shadowColor: AppColors.green,
                    onPressed: () => _saveJob(post: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.grey.shade100, thickness: 1.5, height: 0);
  }
}
// ── Dropdown ──────────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.gradientgreen,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Button ────────────────────────────────────────────────────────────────────

Widget _customButton({
  required String text,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
  required VoidCallback onPressed,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
