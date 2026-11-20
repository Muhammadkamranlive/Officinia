import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JoblistsForJobSeekers/JobOfferMap.dart';
import 'package:client/Server/Model/RecruiterWithJobStats.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class JobSeekerHomeScreen extends StatefulWidget {
  const JobSeekerHomeScreen({super.key});

  @override
  State<JobSeekerHomeScreen> createState() => _JobSeekerHomeScreenState();
}

class _JobSeekerHomeScreenState extends State<JobSeekerHomeScreen> {
  // ── Pagination ────────────────────────────────────────────────
  final List<RecruiterWithJobStats> _recruiters = [];
  DocumentSnapshot?          _lastDoc;
  bool _loadingInitial = true;
  bool _loadingMore    = false;
  bool _hasMore        = true;

  // ── Repos ───────────────────────────────────────────────
  final JobSearchRepository  _jobSearchRepo  = JobSearchRepository();
  final JobOptionRepository  _jobOptionRepo  = JobOptionRepository();
  final JobSeekerRepository  _seekerRepo      = JobSeekerRepository();
  
  List<JobOption> _allOptions = [];
  JobSeekerModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOptions();
    _fetchPage(reset: true);
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final p = await _seekerRepo.getByUid(user.userId);
    if (mounted) setState(() => _profile = p);
  }

  Future<void> _loadOptions() async {
    try {
      final all = await _jobOptionRepo.getAllOptions();
      if (mounted) {
        setState(() {
          _allOptions = all.where((o) => o.isActive).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchPage({bool reset = false}) async {
    if (reset) {
      _jobSearchRepo.clearCache();
      setState(() {
        _recruiters.clear();
        _lastDoc        = null;
        _hasMore        = true;
        _loadingInitial = true;
      });
    }
    if (_loadingMore || !_hasMore && !reset) return;
    setState(() => _loadingMore = true);
    
    try {
      final page = await _jobSearchRepo.getMapRecruitersPage(
        lastDocument: reset ? null : _lastDoc,
      );

      if (!mounted) return;
      setState(() {
        _recruiters.addAll(page.recruiters);
        _lastDoc        = page.lastDoc;
        _hasMore        = page.hasMore;
        _loadingInitial = false;
        _loadingMore    = false;
      });

      // Keep fetching if we have more since map view is nicer with all location points visible
      // Not awaiting to let the UI update first
      if (_hasMore && !_loadingInitial) {
        _fetchPage();
      }
    } catch (_) {
      if (mounted) setState(() { _loadingInitial = false; _loadingMore = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.of(context).size;
    final maxWidth = kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;
    final locale   = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fixed header ──────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      kIsWeb ? 24.0 : 16.0, 16, kIsWeb ? 24.0 : 16.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      _HeaderLayout(
                        name: _profile != null 
                            ? '${_profile!.firstName} ${_profile!.lastName}' 
                            : AppLocalizations.of(context)!.candidate_label,
                        logoUrl: _profile?.logoUrl,
                        greeting: AppLocalizations.of(context)!.find_your_next_role,
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                // ── Content ────────────────────────────────────
                Expanded(
                  child: _loadingInitial 
                      ? const Center(child: CircularProgressIndicator())
                      : JobOfferMapView(
                          recruiters: _recruiters,
                          allOptions: _allOptions,
                          locale:     locale,
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

class _HeaderLayout extends StatelessWidget {
  final String? name;
  final String? logoUrl;
  final String greeting;
  
  const _HeaderLayout({this.name, this.logoUrl, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen)),
          const SizedBox(height: 4),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: (logoUrl?.isNotEmpty == true)
                  ? Image.network(logoUrl!, width: 18, height: 18, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/avatar.png', width: 18, height: 18))
                  : Image.asset('assets/avatar.png', width: 18, height: 18),
            ),
            const SizedBox(width: 4),
            Text(name ?? '—',
                style: const TextStyle(color: AppColors.darkGreen, fontSize: 13)),
          ]),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // Notifications can be opened here
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color:      Colors.black.withOpacity(0.05),
                  blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.notifications_none, color: AppColors.darkGreen),
          ),
        ),
      ],
    );
  }
}