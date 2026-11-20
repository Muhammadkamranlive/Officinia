import 'package:client/AdminPannel/AdminHeader.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/Drawer/JobSeekerDrawer.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/l10n/app_localizations.dart';

class AdminJobListScreen extends StatefulWidget {
  const AdminJobListScreen({super.key});

  @override
  State<AdminJobListScreen> createState() => _AdminJobListScreenState();
}

class _AdminJobListScreenState extends State<AdminJobListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController searchCtrl     = TextEditingController();
  final TextEditingController roleSearchCtrl = TextEditingController();

  final JobSearchRepository _jobSearchRepo = JobSearchRepository();
  final JobOptionRepository _jobOptionRepo = JobOptionRepository();
  final LocationRepository  _locationRepo  = LocationRepository();
  final AdminRepository     adminRepository = AdminRepository();

  late Future<List<JobOfferWithRecruiter>> _jobsFuture;
  late TabController _tabController;

  AdminsModel? admin;
  bool _profileLoaded = false;

  List<JobOption>     _jobTitleOptions = [];
  List<ProvinceModel> _provinces       = [];

  final String _lang = 'en';

  List<String> selectedCities = [];
  List<String> selectedRoles  = [];

  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _loadProfile();
    _loadOptions();
    _jobsFuture = _jobSearchRepo.getAllJobsWithRecruiter();
  }

  Future<void> _loadOptions() async {
    final results = await Future.wait([
      _jobOptionRepo.getJobTitles(),
      _locationRepo.getProvinces(),
    ]);
    if (mounted) {
      setState(() {
        _jobTitleOptions = results[0] as List<JobOption>;
        _provinces       = results[1] as List<ProvinceModel>;
      });
    }
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => _profileLoaded = true);
      return;
    }
    final NotificationRepository notificationRepository = NotificationRepository();
    final notificationList = await notificationRepository.getByUserId(user.userId);
    final admins = await adminRepository.getByUid(user.userId);
    setState(() {
      admin          = admins;
      unreadCount    = notificationList.where((x) => !x.isRead).length;
      _profileLoaded = true;
    });
  }

  List<JobOfferWithRecruiter> _applyFilters(List<JobOfferWithRecruiter> jobs) {
    final query = searchCtrl.text.toLowerCase();
    return jobs.where((job) {
      final matchesQuery = job.jobTitle.toLowerCase().contains(query) ||
          job.pharmacyName.toLowerCase().contains(query);
      final matchesRole =
          selectedRoles.isEmpty || selectedRoles.contains(job.jobTitle);
      final matchesCity =
          selectedCities.isEmpty || selectedCities.contains(job.city);
      return matchesQuery && matchesRole && matchesCity;
    }).toList();
  }

  int get _activeFilterCount => selectedCities.length + selectedRoles.length;

  @override
  Widget build(BuildContext context) {
    if (!_profileLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    // ✅ Web: cap at 900px. Mobile: full width, unchanged.
    final double maxWidth =
        kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: admin != null ? AdminDrawer(admin: admin!) : null,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: maxWidth, // mobile: == size.width, no visual change
            child: Padding(
              padding: EdgeInsets.symmetric(
                // ✅ Mobile: original 16px. Web: 24px breathing room.
                horizontal: kIsWeb ? 24.0 : 16.0,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Admin_Header(
                    jobTitle: AppLocalizations.of(context)!.all_jobs_label,
                    screenName: AppLocalizations.of(context)!.open_closed_jobs_subtitle,
                    unreadCount: unreadCount,
                    onNotificationTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                      _loadProfile();
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.find_pharmacy_job_title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  _AdminSearchBar(
                    controller: searchCtrl,
                    activeFilterCount: _activeFilterCount,
                    onChanged: (_) => setState(() {}),
                    onFilterTap: () => _openFilters(context),
                  ),

                  if (_activeFilterCount > 0) ...[
                    const SizedBox(height: 10),
                    _ActiveFilterBar(
                      selectedCities:  selectedCities,
                      selectedRoles:   selectedRoles,
                      jobTitleOptions: _jobTitleOptions,
                      provinces:       _provinces,
                      lang:            _lang,
                      onRemoveCity:   (c) => setState(() => selectedCities.remove(c)),
                      onRemoveRole:   (r) => setState(() => selectedRoles.remove(r)),
                      onClearAll: () => setState(() {
                        selectedCities.clear();
                        selectedRoles.clear();
                      }),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          TabBar(
                            controller: _tabController,
                            indicatorSize: TabBarIndicatorSize.label,
                            indicatorWeight: 3,
                            indicatorColor: AppColors.greenCeladon,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey.shade500,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            tabs: [
                              Tab(text: AppLocalizations.of(context)!.open_jobs_tab),
                              Tab(text: AppLocalizations.of(context)!.closed_jobs_tab),
                            ],
                          ),

                          const SizedBox(height: 14),

                          FutureBuilder<List<JobOfferWithRecruiter>>(
                            future: _jobsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text(AppLocalizations.of(context)!.failed_load_jobs));
                              }

                              final allJobs = snapshot.data != null
                                  ? _applyFilters(snapshot.data!)
                                  : <JobOfferWithRecruiter>[];

                              final isOpenTab = _tabController.index == 0;
                              final jobs = allJobs.where((job) {
                                return isOpenTab
                                    ? job.jobOffer.isActive
                                    : !job.jobOffer.isActive;
                              }).toList();

                              if (jobs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 60),
                                  child: Center(
                                      child: Text(AppLocalizations.of(context)!.no_jobs_available)),
                                );
                              }

                              // ✅ Web wide: 2-column grid. Mobile: original single column.
                              if (kIsWeb && size.width > 700) {
                                return _WebTwoColumnJobGrid(
                                  jobs: jobs,
                                  buttonText: AppLocalizations.of(context)!.view_details_btn,
                                );
                              }

                              // Mobile: original layout unchanged
                              return Column(
                                children: jobs
                                    .map((item) => _JobCard(
                                          buttonText: "View Details",
                                          job: item,
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFilters(BuildContext context) {
    List<String> tempCities = List.from(selectedCities);
    List<String> tempRoles  = List.from(selectedRoles);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.6,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.filter_jobs_title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setModal(() {
                            tempCities.clear();
                            tempRoles.clear();
                            roleSearchCtrl.clear();
                          }),
                          child: Text(AppLocalizations.of(context)!.clear_all_btn),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      children: [
                        _FilterSection(
                          title: AppLocalizations.of(context)!.location_label,
                          subtitle: tempCities.isEmpty ? AppLocalizations.of(context)!.any_label : null,
                          selectedCount: tempCities.length,
                          child: _provinces.isEmpty
                              ? const _LoadingChips()
                              : _LocationPicker(
                                  provinces: _provinces,
                                  selectedCities: tempCities,
                                  lang: Localizations.localeOf(context).languageCode,
                                  onChanged: (en, selected) =>
                                      setModal(() {
                                    selected
                                        ? tempCities.add(en)
                                        : tempCities.remove(en);
                                  }),
                                ),
                        ),
                        const SizedBox(height: 16),
                        _FilterSection(
                          title: AppLocalizations.of(context)!.job_title_label,
                          selectedCount: tempRoles.length,
                          child: _jobTitleOptions.isEmpty
                              ? const _LoadingChips()
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _jobTitleOptions.map((opt) {
                                    final selected =
                                        tempRoles.contains(opt.en);
                                    return FilterChip(
                                      label: Text(opt.label(Localizations.localeOf(context).languageCode)),
                                      selected: selected,
                                      onSelected: (val) =>
                                          setModal(() {
                                        val
                                            ? tempRoles.add(opt.en)
                                            : tempRoles.remove(opt.en);
                                      }),
                                      selectedColor: AppColors.greenCeladon
                                          .withOpacity(0.25),
                                      checkmarkColor: AppColors.green,
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientgreen,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.green.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedCities = List.from(tempCities);
                              selectedRoles  = List.from(tempRoles);
                            });
                            Navigator.of(sheetContext).pop();
                          },
                          child: Text(
                            "${AppLocalizations.of(context)!.apply_filters_btn}${_buildApplyLabel(tempCities, tempRoles)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _buildApplyLabel(List cities, List roles) {
    final total = cities.length + roles.length;
    return total > 0 ? " ($total)" : "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchCtrl.dispose();
    roleSearchCtrl.dispose();
    super.dispose();
  }
}

// ✅ Web only: 2-column job card grid
class _WebTwoColumnJobGrid extends StatelessWidget {
  final List<JobOfferWithRecruiter> jobs;
  final String buttonText;

  const _WebTwoColumnJobGrid({
    required this.jobs,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<int>>[];
    for (var i = 0; i < jobs.length; i += 2) {
      rows.add([i, if (i + 1 < jobs.length) i + 1]);
    }

    return Column(
      children: rows.map((indices) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _JobCard(job: jobs[indices[0]], buttonText: buttonText),
            ),
            const SizedBox(width: 14),
            indices.length > 1
                ? Expanded(
                    child: _JobCard(
                        job: jobs[indices[1]], buttonText: buttonText),
                  )
                : const Expanded(child: SizedBox.shrink()),
          ],
        );
      }).toList(),
    );
  }
}

// ── All widgets below are completely unchanged ────────────────────────────────

class _FilterSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final int selectedCount;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
    this.subtitle,
    this.selectedCount = 0,
  });

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(width: 8),
                  if (widget.selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.selectedCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(width: 6),
                    Text(widget.subtitle!,
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12)),
                  ],
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _LocationPicker extends StatefulWidget {
  final List<ProvinceModel>                     provinces;
  final List<String>                            selectedCities;
  final String                                  lang;
  final void Function(String en, bool selected) onChanged;

  const _LocationPicker({
    required this.provinces,
    required this.selectedCities,
    required this.lang,
    required this.onChanged,
  });

  @override
  State<_LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<_LocationPicker> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _label(ProvinceModel p) {
    switch (widget.lang) {
      case 'fr': return p.fr;
      case 'ar': return p.ar;
      default:   return p.en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.provinces
        .where((p) =>
            _label(p).toLowerCase().contains(_query.toLowerCase()) ||
            p.en.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search_province_hint,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.green, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.selectedCities.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.selectedCities.map((en) {
              final match = widget.provinces.firstWhere(
                (p) => p.en == en,
                orElse: () => ProvinceModel(
                  en: en, fr: en, ar: en,
                  order: 0, isActive: true,
                  createdAt: DateTime.now(),
                ),
              );
              return Chip(
                label: Text(_label(match),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white)),
                backgroundColor: AppColors.green,
                deleteIconColor: Colors.white,
                onDeleted: () => widget.onChanged(en, false),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final province = filtered[i];
              final selected = widget.selectedCities.contains(province.en);
              return InkWell(
                onTap: () => widget.onChanged(province.en, !selected),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4),
                          color: selected
                              ? AppColors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? AppColors.green
                                : Colors.grey.shade400,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _label(province),
                        style: TextStyle(
                          fontSize: 14,
                          color: selected ? AppColors.green : Colors.black87,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActiveFilterBar extends StatelessWidget {
  final List<String>        selectedCities;
  final List<String>        selectedRoles;
  final List<JobOption>     jobTitleOptions;
  final List<ProvinceModel> provinces;
  final String              lang;
  final void Function(String) onRemoveCity;
  final void Function(String) onRemoveRole;
  final VoidCallback        onClearAll;

  const _ActiveFilterBar({
    required this.selectedCities,
    required this.selectedRoles,
    required this.jobTitleOptions,
    required this.provinces,
    required this.lang,
    required this.onRemoveCity,
    required this.onRemoveRole,
    required this.onClearAll,
  });

  String _cityLabel(String en) {
    final match = provinces.firstWhere(
      (p) => p.en == en,
      orElse: () => ProvinceModel(
        en: en, fr: en, ar: en,
        order: 0, isActive: true,
        createdAt: DateTime.now(),
      ),
    );
    switch (lang) {
      case 'fr': return match.fr;
      case 'ar': return match.ar;
      default:   return match.en;
    }
  }

  String _roleLabel(String en) {
    final match = jobTitleOptions.firstWhere(
      (o) => o.en == en,
      orElse: () => JobOption(
          type: JobOptionType.jobTitle,
          order: 0,
          en: en, fr: en, ar: en,
          createdAt: DateTime.now()),
    );
    return match.label(lang);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedCities.map((c) => _chip(
                _cityLabel(c),
                () => onRemoveCity(c),
                color: Colors.blue.shade50,
                textColor: Colors.blue.shade700,
              )),
          ...selectedRoles.map((r) => _chip(
                _roleLabel(r),
                () => onRemoveRole(r),
                color: Colors.green.shade50,
                textColor: Colors.green.shade700,
              )),
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.close, size: 14, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.clear_all_btn,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, VoidCallback onRemove,
      {required Color color, required Color textColor}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 13, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _LoadingChips extends StatelessWidget {
  const _LoadingChips();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback          onFilterTap;
  final ValueChanged<String>  onChanged;
  final int                   activeFilterCount;

  const _AdminSearchBar({
    required this.controller,
    required this.onFilterTap,
    required this.onChanged,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.black),
                hintText: AppLocalizations.of(context)!.search_job_hint,
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilterTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: activeFilterCount > 0
                      ? AppColors.green.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activeFilterCount > 0
                        ? AppColors.green
                        : Colors.black,
                  ),
                ),
                child: Icon(Icons.tune,
                    color: activeFilterCount > 0
                        ? AppColors.green
                        : Colors.black),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobOfferWithRecruiter job;
  final String                buttonText;

  const _JobCard({required this.job, required this.buttonText});

  String _timeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return l10n.just_now;
    if (diff.inMinutes < 60) return l10n.min_ago(diff.inMinutes);
    if (diff.inHours < 24) return l10n.hours_ago(diff.inHours);
    if (diff.inDays < 7) return l10n.days_ago(diff.inDays);
    if (diff.inDays < 30) return l10n.weeks_ago((diff.inDays / 7).floor());
    if (diff.inDays < 365) return l10n.months_ago((diff.inDays / 30).floor());
    return l10n.years_ago((diff.inDays / 365).floor());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RecruiterJobDetailScreen(job: job)),
      ),
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
                  radius: 22,
                  backgroundColor: AppColors.greenCeladon,
                  child: job.recruiter.logoUrl != null &&
                          job.recruiter.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            job.recruiter.logoUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.work_outline,
                                color: Colors.white),
                          ),
                        )
                      : const Icon(Icons.work_outline, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.jobTitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      Text(job.pharmacyName,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.jobType, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 17),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.greenCeladon,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                Text(_timeAgo(context, job.createdAt),
                    style:
                        const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}