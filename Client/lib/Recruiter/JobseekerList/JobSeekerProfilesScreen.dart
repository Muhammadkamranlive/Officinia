
import 'dart:async';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';

import 'package:client/Recruiter/JobseekerList/SkillSearchOverlay.dart';
import 'package:client/Recruiter/JobseekerList/map.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobOptionRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillMetaRepository.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

const int _kPageSize = 250;

class JobSeekerProfilesScreen extends StatefulWidget {
  const JobSeekerProfilesScreen({super.key});

  @override
  State<JobSeekerProfilesScreen> createState() =>
      _JobSeekerProfilesScreenState();
}

class _JobSeekerProfilesScreenState extends State<JobSeekerProfilesScreen>
    with SingleTickerProviderStateMixin {

  // ── Pagination ────────────────────────────────────────────────
  final List<JobSeekerModel> _seekers = [];
  DocumentSnapshot?          _lastDoc;
  bool _loadingInitial = true;
  bool _loadingMore    = false;
  bool _hasMore        = true;

  // ── Job options ───────────────────────────────────────────────
  final _jobOptionRepo        = JobOptionRepository();
  List<JobOption> _allOptions = [];
  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadOptions();
    _fetchPage(reset: true);
  }

  @override
  void dispose() {
    super.dispose();
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
      setState(() {
        _seekers.clear();
        _lastDoc        = null;
        _hasMore        = true;
        _loadingInitial = true;
      });
    }
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      Query q = FirebaseFirestore.instance
          .collection('JobSeekers')
          .orderBy('createdAt', descending: true)
          .limit(_kPageSize);
      if (_lastDoc != null) q = q.startAfterDocument(_lastDoc!);
      final snap  = await q.get();
      final docs  = snap.docs;
      final items = docs
          .map((d) =>
              JobSeekerModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      setState(() {
        _seekers.addAll(items);
        _lastDoc        = docs.isNotEmpty ? docs.last : _lastDoc;
        _hasMore        = docs.length == _kPageSize;
        _loadingInitial = false;
        _loadingMore    = false;
      });
    } catch (_) {
      setState(() { _loadingInitial = false; _loadingMore = false; });
    }
  }

  String _normalize(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

  JobOption? _optionById(String id) {
    try { return _allOptions.firstWhere((o) => o.docId == id); }
    catch (_) { return null; }
  }



  @override
  Widget build(BuildContext context) {
    final user     = context.read<AuthProvider>().user;
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

                // ── Fixed header (always visible) ──────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      kIsWeb ? 24.0 : 16.0, 16, kIsWeb ? 24.0 : 16.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (user?.role == UserRole.admin)
                        const DashboardHeader()
                      else
                        const DashboardHeader1(),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                // ── Content ────────────────────────────────────
                Expanded(
                  child: _loadingInitial 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.greenCeladon))
                      : JobSeekerMapView(
                          seekers:    _seekers,
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



// ═══════════════════════════════════════════════════════════════════
//  DASHBOARD HEADERS  (unchanged)
// ═══════════════════════════════════════════════════════════════════
class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});
  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final _repo  = AdminRepository();
  AdminsModel? _profile;
  bool         _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final p = await _repo.getByUid(user.userId);
    if (mounted) setState(() { _profile = p; _loading = false; });
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Padding(
        padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    return _HeaderLayout(pharmacyName: _profile?.pharmacyName, logoUrl: _profile?.logoUrl);
  }
}

class DashboardHeader1 extends StatefulWidget {
  const DashboardHeader1({super.key});
  @override
  State<DashboardHeader1> createState() => _DashboardHeaderState1();
}

class _DashboardHeaderState1 extends State<DashboardHeader1> {
  final _repo = RecruiterRepository();
  Recruiter?  _profile;
  bool        _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final p = await _repo.getByUid(user.userId);
    if (mounted) setState(() { _profile = p; _loading = false; });
  }
  @override
  Widget build(BuildContext context) {
    if (_loading) return const Padding(
        padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    return _HeaderLayout(pharmacyName: _profile?.pharmacyName, logoUrl: _profile?.logoUrl);
  }
}

class _HeaderLayout extends StatelessWidget {
  final String? pharmacyName;
  final String? logoUrl;
  const _HeaderLayout({this.pharmacyName, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context)!.job_seeker_profiles,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen)),
          const SizedBox(height: 4),
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: (logoUrl?.isNotEmpty == true)
                  ? Image.network(logoUrl!, width: 18, height: 18, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/avatar.png', width: 18, height: 18))
                  : Image.asset('assets/avatar.png', width: 18, height: 18),
            ),
            const SizedBox(width: 4),
            Text(pharmacyName ?? '—',
                style: const TextStyle(color: AppColors.darkGreen, fontSize: 13)),
          ]),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen())),
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