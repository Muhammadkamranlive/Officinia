import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/GoogleMap/LocationPickerScreen.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Profile/JobSeekerLogoUploadScreen.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ExperienceLevelModel.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/ExperienceLevelRepository.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillMetaRepository.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

// ── Adjust path to wherever you placed the file ──────────────

class JobSeekerAccountScreen extends StatefulWidget {
  final JobSeekerFormMode mode;
  const JobSeekerAccountScreen({super.key, required this.mode});

  @override
  State<JobSeekerAccountScreen> createState() => _JobSeekerAccountScreenState();
}

class _JobSeekerAccountScreenState extends State<JobSeekerAccountScreen> {
  // ── Repos ──────────────────────────────────────────────────
  final _repo           = JobSeekerRepository();
  final _skillMetaRepo  = SkillMetaRepository();
  final _jobOptionRepo  = JobOptionRepository();
  final _experienceRepo = ExperienceLevelRepository();
  final _locationRepo   = LocationRepository();

  // ── Text controllers ───────────────────────────────────────
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl  = TextEditingController();
  final educationCtrl = TextEditingController();
  final emailCtrl     = TextEditingController();
  final phoneCtrl     = TextEditingController();
  final double inputFieldHeight = 66;

  // ── Firestore option lists ─────────────────────────────────
  List<JobOption>            _jobTitleOptions   = [];
  List<JobOption>            _skillOptions      = [];
  List<ExperienceLevelModel> _experienceOptions = [];
  List<ProvinceModel>        _provinceOptions   = [];
  List<CityModel>            _cityOptions       = [];

  // ── Dropdowns ─────────────────────────────────────────────
  String? selectedProvince;
  String? selectedCity;

  // ── Profile state ──────────────────────────────────────────
  bool    isNameVisible  = true;
  String? desiredPosition;
  String? experienceLevel;
  JobSeekerModel? jobSeeker;
  bool loading = true;
  String? _phoneError;

  List<String>        skills       = [];
  Map<String, String> skillStatuses = {};

  // ── Location state (from map picker) ──────────────────────
  double _latitude      = 0;
  double _longitude     = 0;
  String _streetAddress = '';

  bool get isView   => widget.mode == JobSeekerFormMode.view;
  bool get isEdit   => widget.mode == JobSeekerFormMode.edit;
  bool get isCreate => widget.mode == JobSeekerFormMode.create;

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    educationCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  // ── Load ───────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final results = await Future.wait([
        _jobOptionRepo.getJobTitles(),
        _jobOptionRepo.getSkills(),
        _experienceRepo.getExperienceLevels(),
        _locationRepo.getProvinces(),
        _repo.getByUid(user.userId),
      ]);

      _jobTitleOptions   = results[0] as List<JobOption>;
      _skillOptions      = results[1] as List<JobOption>;
      _experienceOptions = results[2] as List<ExperienceLevelModel>;
      _provinceOptions   = results[3] as List<ProvinceModel>;
      jobSeeker          = results[4] as JobSeekerModel?;

      emailCtrl.text = user.email;

      if (jobSeeker != null) {
        firstNameCtrl.text = jobSeeker!.firstName;
        lastNameCtrl.text  = jobSeeker!.lastName;
        educationCtrl.text = jobSeeker!.educationBackground ?? '';
        isNameVisible      = jobSeeker!.isNameVisible;
        desiredPosition    = jobSeeker!.desiredPosition;
        experienceLevel    = jobSeeker!.experienceDetails;
        skills             = List<String>.from(jobSeeker!.skills);

        // ── Pre-fill location from existing data ──────────────
        _latitude      = jobSeeker!.latitude;
        _longitude     = jobSeeker!.longitude;
        _streetAddress = jobSeeker!.streetAddress;

        // Restore province → city
        final matchedProv = _provinceOptions
            .where((p) => p.en == jobSeeker!.province)
            .firstOrNull;
        if (matchedProv != null) {
          selectedProvince = matchedProv.docId;
          _cityOptions = await _locationRepo.getCities(matchedProv.docId!);
          selectedCity = _cityOptions
              .where((c) => c.en == jobSeeker!.city)
              .firstOrNull
              ?.docId;
        }

        // Phone
        final raw = user.phone ?? jobSeeker!.phoneNumber;
        phoneCtrl.text = raw.startsWith('+213')
            ? raw.replaceFirst('+213', '')
            : raw;

        await _loadSkillStatuses();
      }
    } catch (e) {
      debugPrint('JobSeeker load error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _onProvinceChanged(String? provinceDocId) async {
    setState(() {
      selectedProvince = provinceDocId;
      selectedCity     = null;
      _cityOptions     = [];
    });
    if (provinceDocId == null) return;
    final cities = await _locationRepo.getCities(provinceDocId);
    if (mounted) setState(() => _cityOptions = cities);
  }

  Future<void> _loadSkillStatuses() async {
    if (jobSeeker == null) return;
    try {
      final metas =
          await _skillMetaRepo.getSkillsForJobSeeker(jobSeeker!.userId);
      final Map<String, String> statuses = {};
      for (final skill in skills) {
        final meta = metas.firstWhere(
          (m) => m.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: jobSeeker!.userId,
            skill: skill,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        statuses[skill] = meta.status;
      }
      if (mounted) setState(() => skillStatuses = statuses);
    } catch (e) {
      debugPrint('Skill status load error: $e');
    }
  }

  // ── Open location picker ───────────────────────────────────
  Future<void> _openLocationPicker() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Build a temporary JobSeekerModel to pass into the picker.
    // If jobSeeker is null (create mode), we create a minimal shell.
    final current = jobSeeker ?? JobSeekerModel(
      userId:          user.userId,
      firstName:       firstNameCtrl.text,
      lastName:        lastNameCtrl.text,
      isNameVisible:   isNameVisible,
      email:           emailCtrl.text,
      phoneNumber:     '+213${phoneCtrl.text.trim()}',
      desiredPosition: desiredPosition ?? '',
      skills:          skills,
      createdAt:       DateTime.now(),
      province:        '',
      city:            '',
      streetAddress:   _streetAddress,
      latitude:        _latitude,
      longitude:       _longitude,
    );

    // In create mode, docId is null so picker shows map but save inside
    // picker will be skipped (no docId). We handle save on form submit.
    final updated = await Navigator.push<JobSeekerModel>(
      context,
      MaterialPageRoute(
        builder: (_) => JobSeekerLocationPicker(jobSeeker: current),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        jobSeeker      = updated;
        _latitude      = updated.latitude;
        _longitude     = updated.longitude;
        _streetAddress = updated.streetAddress;
      });
    }
  }

  // ── Validation ─────────────────────────────────────────────
  bool _isValidAlgerianPhone(String phone) =>
      RegExp(r'^[567]\d{8}$').hasMatch(phone);

  bool _validatePhone(BuildContext context) {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty) { _phoneError = AppLocalizations.of(context)!.phone_required_error; return false; }
    if (phone.length != 9) { _phoneError = AppLocalizations.of(context)!.phone_nine_digits_error; return false; }
    if (!_isValidAlgerianPhone(phone)) {
      _phoneError = AppLocalizations.of(context)!.phone_invalid_start_error;
      return false;
    }
    _phoneError = null;
    return true;
  }

  // ── Save ───────────────────────────────────────────────────
  Future<void> _save(BuildContext context) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (!_validatePhone(context)) { setState(() {}); return; }

    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        desiredPosition == null ||
        skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.fill_required_fields_error),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final provinceEN = _provinceOptions
        .where((p) => p.docId == selectedProvince).firstOrNull?.en ?? '';
    final cityEN = _cityOptions
        .where((c) => c.docId == selectedCity).firstOrNull?.en ?? '';

    final data = JobSeekerModel(
      userId:              user.userId,
      firstName:           firstNameCtrl.text.trim(),
      lastName:            lastNameCtrl.text.trim(),
      isNameVisible:       isNameVisible,
      email:               emailCtrl.text.trim(),
      province:            provinceEN,
      city:                cityEN,
      streetAddress:       _streetAddress,   // ← from map picker
      latitude:            _latitude,         // ← from map picker
      longitude:           _longitude,        // ← from map picker
      phoneNumber:         '+213${phoneCtrl.text.trim()}',
      desiredPosition:     desiredPosition!,
      skills:              skills,
      educationBackground: educationCtrl.text.trim().isEmpty
          ? null : educationCtrl.text.trim(),
      experienceDetails:   experienceLevel,
      createdAt:           jobSeeker?.createdAt ?? DateTime.now(),
      isActive:            jobSeeker?.isActive ?? 'Pending',
      docId:               jobSeeker?.docId,
      logoUrl:             jobSeeker?.logoUrl,
    );

    if (isCreate) {
      await _repo.add(data);
      for (final skill in skills) {
        await _skillMetaRepo.getOrCreateSkillMeta(
          jobSeekerId: user.userId, skill: skill);
      }
    } else {
      await _repo.update(data.docId!, data);
    }

    Navigator.pushNamed(context, AppRoutes.jobSeekerDash);
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isCreate ? AppLocalizations.of(context)!.create_profile_title : isEdit ? AppLocalizations.of(context)!.edit_profile_title : AppLocalizations.of(context)!.my_profile_title,
          style: const TextStyle(
              color: AppColors.darkGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // Profile picture
          if (!isCreate) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) =>
                      JobSeekerLogoUploadScreen(recruiter: jobSeeker!)));
              },
              child: Text(AppLocalizations.of(context)!.update_profile_picture),
            ),
            const SizedBox(height: 20),
          ],

          // ── Personal info ────────────────────────────────
          _card(AppLocalizations.of(context)!.personal_information_title, Column(children: [
            _InputField(label: AppLocalizations.of(context)!.first_name_label, hint: 'Ahmed',
                enabled: !isView, controller: firstNameCtrl),
            const SizedBox(height: 12),
            _InputField(label: AppLocalizations.of(context)!.last_name_label, hint: 'Ben Ali',
                enabled: !isView, controller: lastNameCtrl),
            const SizedBox(height: 12),
            _InputField(label: AppLocalizations.of(context)!.email_label, hint: '',
                enabled: true, controller: emailCtrl),
            const SizedBox(height: 12),
            _phoneField(),
            const SizedBox(height: 12),
            SwitchListTile(
              value: isNameVisible,
              onChanged: isView ? null : (v) => setState(() => isNameVisible = v),
              title: Text(AppLocalizations.of(context)!.show_my_name_label),
            ),
          ])),
          const SizedBox(height: 20),

          // ── Location ─────────────────────────────────────
          _card(AppLocalizations.of(context)!.location_information_title, Column(children: [
            const SizedBox(height: 4),
            _provinceDropdown(context),
            const SizedBox(height: 12),
            _cityDropdown(context),
            const SizedBox(height: 12),
            if (!isCreate) ...[
            // ── MAP LOCATION PICKER TILE ──────────────────
            _locationPickerTile(context),
            ]
          ])),
          const SizedBox(height: 20),

          // ── Job title ─────────────────────────────────────
          _card(AppLocalizations.of(context)!.current_job_title_title,
              Column(children: [_desiredPositionField(context)])),
          const SizedBox(height: 10),

          // ── Skills ───────────────────────────────────────
          _card(AppLocalizations.of(context)!.skills_title, Column(children: [
            ...skills.map((s) => _skillTile(context, s)),
            if (!isView)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.add_skill_btn),
                onPressed: () => _openSkillBottomSheet(context),
              ),
          ])),
          const SizedBox(height: 20),

          // ── Background ───────────────────────────────────
          _card(AppLocalizations.of(context)!.background_title, Column(children: [
            _InputField(label: AppLocalizations.of(context)!.education_label, hint: 'Pharmacy Degree',
                enabled: !isView, controller: educationCtrl, maxLines: 2),
            const SizedBox(height: 12),
            _experienceField(context),
          ])),
          const SizedBox(height: 14),

          if (!isView)
            _customButton(
              text: isCreate ? AppLocalizations.of(context)!.create_profile_title : AppLocalizations.of(context)!.save_changes_btn,
              onPressed: () => _save(context),
              size: MediaQuery.of(context).size,
              gradient: AppColors.gradientdarkgreen,
              shadowColor: AppColors.darkGreen,
            ),
          const SizedBox(height: 54),
        ]),
      ),
    );
  }

  // ── Location picker tile ───────────────────────────────────
  Widget _locationPickerTile(BuildContext context) {
    final hasLocation = _latitude != 0 && _longitude != 0;

    return GestureDetector(
      onTap: isView ? null : _openLocationPicker,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.gradientgreen,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [

            // icon badge
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: hasLocation
                    ? AppColors.darkGreen.withOpacity(.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasLocation
                    ? Icons.location_on_rounded
                    : Icons.add_location_alt_rounded,
                color: hasLocation
                    ? AppColors.darkGreen
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // address text
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.my_location_title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  )),
                const SizedBox(height: 2),
                Text(
                  _streetAddress.isNotEmpty
                      ? _streetAddress
                      : AppLocalizations.of(context)!.tap_to_set_location,
                  style: TextStyle(
                    fontSize: 14,
                    color: _streetAddress.isNotEmpty
                        ? Colors.black87
                        : Colors.grey.shade400,
                    fontWeight: _streetAddress.isNotEmpty
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasLocation) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${_latitude.toStringAsFixed(4)}, '
                    '${_longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGreen.withOpacity(.6),
                    )),
                ],
              ],
            )),

            if (!isView) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasLocation ? AppLocalizations.of(context)!.change_location_btn : AppLocalizations.of(context)!.set_location_btn,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  // ── Skill tile ─────────────────────────────────────────────
  Widget _skillTile(BuildContext context, String skillKey) {
    final display = _skillOptions
        .where((o) => o.en == skillKey).firstOrNull?.en ?? skillKey;
    final status = skillStatuses[skillKey] ?? 'Pending';
    final localizedStatus = status == 'Verified' ? AppLocalizations.of(context)!.status_verified 
        : status == 'Rejected' ? AppLocalizations.of(context)!.status_rejected 
        : AppLocalizations.of(context)!.status_pending;
    final color = status == 'Verified'
        ? Colors.green
        : status == 'Rejected'
            ? Colors.red
            : Colors.orange;

    return ListTile(
      title: Text(display),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Chip(label: Text(localizedStatus),
            backgroundColor: color,
            labelStyle: const TextStyle(color: AppColors.white)),
        if (!isView)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() {
              skills.remove(skillKey);
              skillStatuses.remove(skillKey);
            }),
          ),
      ]),
    );
  }

  // ── Skill bottom sheet ─────────────────────────────────────
  void _openSkillBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(children: [
          const SizedBox(height: 12),
          _handle(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.select_skills_title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: _skillOptions.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.no_skills_available))
                : StatefulBuilder(builder: (ctx, setSheet) {
                    return ListView.separated(
                      itemCount: _skillOptions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final skill      = _skillOptions[i];
                        final isSelected = skills.contains(skill.en);
                        return ListTile(
                          title: Text(skill.en),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.green
                                : Colors.grey,
                          ),
                          onTap: () {
                            setSheet(() {
                              setState(() {
                                if (isSelected) {
                                  skills.remove(skill.en);
                                  skillStatuses.remove(skill.en);
                                } else {
                                  skills.add(skill.en);
                                  skillStatuses[skill.en] = 'Pending';
                                }
                              });
                            });
                          },
                        );
                      },
                    );
                  }),
          ),
        ]),
      ),
    );
  }

  // ── Desired position ───────────────────────────────────────
  Widget _desiredPositionField(BuildContext context) {
    final display = _jobTitleOptions
        .where((o) => o.en == desiredPosition).firstOrNull?.en
        ?? desiredPosition
        ?? AppLocalizations.of(context)!.select_job_title_hint;
    return GestureDetector(
      onTap: isView ? null : () => _openDesiredPositionSheet(context),
      child: _pickerContainer(text: display, isEmpty: desiredPosition == null),
    );
  }

  void _openDesiredPositionSheet(BuildContext context) => _openPickerSheet(
    context: context,
    title: AppLocalizations.of(context)!.select_job_title_hint,
    items: _jobTitleOptions,
    selectedKey: desiredPosition,
    onSelect: (key) => setState(() => desiredPosition = key),
  );

  // ── Experience ─────────────────────────────────────────────
  Widget _experienceField(BuildContext context) {
    final display = _experienceOptions
        .where((o) => o.en == experienceLevel).firstOrNull?.en
        ?? experienceLevel
        ?? AppLocalizations.of(context)!.job_experience_hint;
    return GestureDetector(
      onTap: isView ? null : () => _openExperienceSheet(context),
      child: _pickerContainer(text: display, isEmpty: experienceLevel == null),
    );
  }

  void _openExperienceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(children: [
          const SizedBox(height: 12),
          _handle(),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.job_experience_hint,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: _experienceOptions.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.no_experience_available))
                : ListView.separated(
                    itemCount: _experienceOptions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final level = _experienceOptions[i];
                      return ListTile(
                        title: Text(level.en),
                        trailing: experienceLevel == level.en
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() => experienceLevel = level.en);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  void _openPickerSheet({
    required BuildContext context,
    required String title,
    required List<JobOption> items,
    required String? selectedKey,
    required void Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        child: Column(children: [
          const SizedBox(height: 12),
          _handle(),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.no_options_available))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final opt = items[i];
                      return ListTile(
                        title: Text(opt.en),
                        trailing: selectedKey == opt.en
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          onSelect(opt.en);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  // ── Province dropdown ──────────────────────────────────────
  Widget _provinceDropdown(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen),
    child: Container(
      height: inputFieldHeight,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedProvince,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.wilaya_label, border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12)),
        hint: Text(AppLocalizations.of(context)!.select_province_hint),
        items: _provinceOptions
            .map((p) => DropdownMenuItem(value: p.docId, child: Text(p.en)))
            .toList(),
        onChanged: isView ? null : _onProvinceChanged,
      ),
    ),
  );

  // ── City dropdown ──────────────────────────────────────────
  Widget _cityDropdown(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen),
    child: Container(
      height: inputFieldHeight,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedCity,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.city_label, border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12)),
        hint: Text(selectedProvince == null
            ? AppLocalizations.of(context)!.select_province_first
            : _cityOptions.isEmpty ? AppLocalizations.of(context)!.loading_hint : AppLocalizations.of(context)!.select_city_hint),
        items: _cityOptions
            .map((c) => DropdownMenuItem<String>(
                value: c.docId, child: Text(c.en)))
            .toList(),
        onChanged: (isView || selectedProvince == null)
            ? null
            : (val) => setState(() => selectedCity = val),
      ),
    ),
  );

  // ── Shared helpers ─────────────────────────────────────────
  Widget _pickerContainer({required String text, required bool isEmpty}) =>
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.gradientgreen),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Text(text,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isEmpty ? Colors.grey : Colors.black,
                    fontSize: 14))),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ]),
        ),
      );

  Widget _handle() => Container(
    width: 40, height: 4,
    decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10)));

  Widget _card(String title, Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppUI.card,
      borderRadius: BorderRadius.circular(AppUI.radius),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12)
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      child,
    ]),
  );

  Widget _customButton({
    required String text,
    required void Function()? onPressed,
    required Size size,
    required Gradient gradient,
    required Color shadowColor,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: shadowColor.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(text,
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            )),
        ),
      );

  Widget _phoneField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.gradientgreen),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Image.asset('assets/dz.png',
                width: 28, height: 20, fit: BoxFit.cover),
            const SizedBox(width: 8),
            const Text('+213',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.number,
                enabled: !isView,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                onChanged: (_) => setState(() => _phoneError = null),
                decoration: const InputDecoration(
                  border: InputBorder.none, hintText: '5XXXXXXXX'),
              ),
            ),
          ]),
        ),
      ),
      if (_phoneError != null)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 6),
          child: Text(_phoneError!,
              style: const TextStyle(color: Colors.red, fontSize: 12))),
    ],
  );
}

// ── Input Field ───────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label, hint;
  final bool   enabled;
  final int    maxLines;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.enabled,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
        ),
      ),
    ),
  );
}