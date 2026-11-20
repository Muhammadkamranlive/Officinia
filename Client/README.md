import 'dart:async';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Recruiter/JobseekerList/SkillSearchOverlay.dart';
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

const int _kPageSize = 10;

class JobSeekerProfilesScreen extends StatefulWidget {
  const JobSeekerProfilesScreen({super.key});

  @override
  State<JobSeekerProfilesScreen> createState() =>
      _JobSeekerProfilesScreenState();
}

class _JobSeekerProfilesScreenState extends State<JobSeekerProfilesScreen> {
  // ── Pagination ───────────────────────────────────────────────
  final List<JobSeekerModel> _seekers = [];
  DocumentSnapshot? _lastDoc;
  bool _loadingInitial = true;
  bool _loadingMore    = false;
  bool _hasMore        = true;

  // ── Filters ──────────────────────────────────────────────────
  String selectedCity  = "All";
  String searchQuery   = "";

  // ── Job options (skills + job titles from Firestore) ─────────
  final _jobOptionRepo            = JobOptionRepository();
  List<JobOption> _allOptions     = [];   // ALL loaded options for label lookup
  SkillFilterResult _activeFilter = const SkillFilterResult(
    skillIds: [],
    jobTitleIds: [],
  );

  // ── Scroll ───────────────────────────────────────────────────
  final ScrollController _scrollController = ScrollController();

  // ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadOptions();          // ← single call loads BOTH skills + job titles
    _fetchPage(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !_loadingMore &&
          _hasMore) {
        _fetchPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Load all options once (skills + job titles in one call) ──
  Future<void> _loadOptions() async {
    try {
      final all = await _jobOptionRepo.getAllOptions();
      if (mounted) {
        setState(() {
          // Keep only active options; sort by order for consistent label lookup
          _allOptions = all.where((o) => o.isActive).toList()
            ..sort((a, b) => a.order.compareTo(b.order));
        });
      }
    } catch (_) {}
  }

  // ── Firestore paginated fetch ─────────────────────────────────
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
      Query query = FirebaseFirestore.instance
          .collection('JobSeekers')
          .orderBy('createdAt', descending: true)
          .limit(_kPageSize);

      if (_lastDoc != null) query = query.startAfterDocument(_lastDoc!);

      final snapshot   = await query.get();
      final docs       = snapshot.docs;
      final newSeekers = docs
          .map((d) => JobSeekerModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
          .toList();

      setState(() {
        _seekers.addAll(newSeekers);
        _lastDoc        = docs.isNotEmpty ? docs.last : _lastDoc;
        _hasMore        = docs.length == _kPageSize;
        _loadingInitial = false;
        _loadingMore    = false;
      });
    } catch (_) {
      setState(() {
        _loadingInitial = false;
        _loadingMore    = false;
      });
    }
  }

  // ── Normalise for fuzzy matching ──────────────────────────────
  String _normalize(String v) =>
      v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

  // ── Resolve a docId → JobOption (null-safe) ───────────────────
  JobOption? _optionById(String id) {
    try {
      return _allOptions.firstWhere((o) => o.docId == id);
    } catch (_) {
      return null;
    }
  }

  // ── Client-side filtering ─────────────────────────────────────
  List<JobSeekerModel> get _filtered {
    return _seekers.where((seeker) {

      // ── Skills: seeker must have ALL selected skills ──────────
      final matchesSkills = _activeFilter.skillIds.isEmpty ||
          _activeFilter.skillIds.every((id) {
            final opt = _optionById(id);
            if (opt == null) return false;
            // Compare normalised English label against seeker's skill list
            final needle = _normalize(opt.en);
            return seeker.skills.any((s) => _normalize(s) == needle);
          });

      // ── Job titles: seeker must match ANY selected title ──────
      final matchesRoles = _activeFilter.jobTitleIds.isEmpty ||
          _activeFilter.jobTitleIds.any((id) {
            final opt = _optionById(id);
            if (opt == null) return false;
            return _normalize(seeker.desiredPosition) == _normalize(opt.en);
          });

      // ── City ──────────────────────────────────────────────────
      final matchesCity =
          selectedCity == "All" || seeker.city == selectedCity;

      // ── Free-text search ──────────────────────────────────────
      final q = _normalize(searchQuery);
      final matchesSearch = q.isEmpty ||
          _normalize('${seeker.firstName} ${seeker.lastName}').contains(q) ||
          seeker.skills.any((s) => _normalize(s).contains(q)) ||
          _normalize(seeker.desiredPosition).contains(q);

      return matchesSkills && matchesRoles && matchesCity && matchesSearch;
    }).toList();
  }

  // ── Open Google-Maps-style overlay ───────────────────────────
  Future<void> _openSkillOverlay() async {
    final locale = Localizations.localeOf(context).languageCode;
    final result = await SkillSearchOverlay.show(
      context,
      initialSkillIds:    _activeFilter.skillIds,
      initialJobTitleIds: _activeFilter.jobTitleIds,
      languageCode:       locale,
    );
    if (result != null && mounted) {
      setState(() => _activeFilter = result);
    }
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user     = context.read<AuthProvider>().user;
    final size     = MediaQuery.of(context).size;
    final maxWidth =
        kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;
    final locale   = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 24.0 : 16.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // ── Header ──────────────────────────────────
                  if (user?.role == UserRole.admin)
                    const DashboardHeader()
                  else
                    const DashboardHeader1(),

                  // ── Filter bar (tap → overlay) ───────────────
                  GestureDetector(
                    onTap: _openSkillOverlay,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _activeFilter.isEmpty
                              ? Colors.black
                              : AppColors.darkGreen,
                          width: _activeFilter.isEmpty ? 1 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppColors.darkGreen,
                          ),
                          const SizedBox(width: 10),

                          // ── Collapsed preview ────────────────
                          Expanded(
                            child: _activeFilter.isEmpty
                                ? const Text(
                                    'Filter by skills or positions…',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  )
                                : _CollapsedFilterPreview(
                                    activeFilter: _activeFilter,
                                    allOptions:   _allOptions,
                                    locale:       locale,
                                  ),
                          ),

                          // ── Clear ────────────────────────────
                          if (!_activeFilter.isEmpty)
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _activeFilter = const SkillFilterResult(
                                    skillIds:    [],
                                    jobTitleIds: [],
                                  )),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(Icons.close,
                                    size: 18,
                                    color: Colors.grey.shade500),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── List / Grid ──────────────────────────────
                  Expanded(child: _buildList(size)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  Widget _buildList(Size size) {
    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered;

    if (filtered.isEmpty && !_hasMore) {
      return const Center(child: Text('No job seekers found'));
    }

    if (kIsWeb && size.width > 700) {
      return _WebTwoColumnGrid(
        seekers:          filtered,
        scrollController: _scrollController,
        loadingMore:      _loadingMore,
        hasMore:          _hasMore,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount:  filtered.length + 1,
      itemBuilder: (_, index) {
        if (index < filtered.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: JobSeekerCard(seeker: filtered[index]),
          );
        }
        return _PaginationFooter(
          loadingMore: _loadingMore,
          hasMore:     _hasMore,
          onLoadMore:  _fetchPage,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  COLLAPSED FILTER PREVIEW  — chips shown inside the filter bar
// ─────────────────────────────────────────────────────────────────
class _CollapsedFilterPreview extends StatelessWidget {
  final SkillFilterResult activeFilter;
  final List<JobOption>   allOptions;
  final String            locale;

  const _CollapsedFilterPreview({
    required this.activeFilter,
    required this.allOptions,
    required this.locale,
  });

  JobOption? _find(String id) {
    try {
      return allOptions.firstWhere((o) => o.docId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Merge skill ids + jobTitle ids into one ordered list for preview
    final allIds = [
      ...activeFilter.skillIds,
      ...activeFilter.jobTitleIds,
    ];
    final visibleIds = allIds.take(3).toList();
    final overflow   = allIds.length - visibleIds.length;

    return Wrap(
      spacing:    6,
      runSpacing: 4,
      children: [
        ...visibleIds.map((id) {
          final opt     = _find(id);
          final label   = opt?.label(locale) ?? id;
          final isSkill = opt?.type == JobOptionType.skill;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isSkill
                  ? AppColors.darkGreen.withOpacity(0.1)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,   // ← resolved human label, never the raw docId
              style: TextStyle(
                fontSize: 11,
                color: isSkill
                    ? AppColors.darkGreen
                    : Colors.blue.shade700,
              ),
            ),
          );
        }),
        if (overflow > 0)
          Text(
            '+$overflow more',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  PAGINATION FOOTER
// ─────────────────────────────────────────────────────────────────
class _PaginationFooter extends StatelessWidget {
  final bool         loadingMore;
  final bool         hasMore;
  final VoidCallback onLoadMore;

  const _PaginationFooter({
    required this.loadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: OutlinedButton.icon(
            onPressed: onLoadMore,
            icon:  const Icon(Icons.expand_more_rounded),
            label: const Text('Load more'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Divider(
                    color: Colors.grey.shade300, endIndent: 12)),
            Text('All profiles loaded',
                style: TextStyle(
                    color: Colors.grey.shade400, fontSize: 12)),
            Flexible(
                child: Divider(
                    color: Colors.grey.shade300, indent: 12)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  WEB 2-COLUMN GRID
// ─────────────────────────────────────────────────────────────────
class _WebTwoColumnGrid extends StatelessWidget {
  final List<JobSeekerModel> seekers;
  final ScrollController     scrollController;
  final bool                 loadingMore;
  final bool                 hasMore;

  const _WebTwoColumnGrid({
    required this.seekers,
    required this.scrollController,
    required this.loadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<JobSeekerModel>>[];
    for (var i = 0; i < seekers.length; i += 2) {
      rows.add(seekers.sublist(
          i, i + 2 > seekers.length ? seekers.length : i + 2));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount:  rows.length + 1,
      itemBuilder: (context, rowIndex) {
        if (rowIndex < rows.length) {
          final row = rows[rowIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: JobSeekerCard(seeker: row[0])),
                const SizedBox(width: 14),
                row.length > 1
                    ? Expanded(child: JobSeekerCard(seeker: row[1]))
                    : const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
        }
        return _PaginationFooter(
          loadingMore: loadingMore,
          hasMore:     hasMore,
          onLoadMore:  () {},
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  JOB SEEKER CARD
// ─────────────────────────────────────────────────────────────────
class JobSeekerCard extends StatefulWidget {
  final JobSeekerModel seeker;
  const JobSeekerCard({super.key, required this.seeker});

  @override
  State<JobSeekerCard> createState() => _JobSeekerCardState();
}

class _JobSeekerCardState extends State<JobSeekerCard> {
  final ProfileViewsRepository _profileViewsRepo = ProfileViewsRepository();
  final SkillMetaRepository    _skillMetaRepo     = SkillMetaRepository();

  StreamSubscription?         _skillMetaSub;
  bool                        _loading       = false;
  int                         _verifiedCount = 0;
  Map<String, String>         _skillsWithStatus = {};
  bool                        _loadingSkills = true;

  @override
  void initState() {
    super.initState();
    _listenToSkillUpdates();
  }

  @override
  void dispose() {
    _skillMetaSub?.cancel();
    super.dispose();
  }

  void _listenToSkillUpdates() {
    _skillMetaSub = _skillMetaRepo.collection
        .where('jobSeekerId', isEqualTo: widget.seeker.userId)
        .snapshots()
        .listen((snapshot) {
      final skillMetas = snapshot.docs
          .map((doc) => SkillVerificationMeta.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final Map<String, String> statuses = {};
      for (final skill in widget.seeker.skills) {
        final meta = skillMetas.firstWhere(
          (m) => m.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: widget.seeker.userId,
            skill:       skill,
            createdAt:   DateTime.now(),
            updatedAt:   DateTime.now(),
          ),
        );
        statuses[skill] = meta.status;
      }

      final verifiedCount =
          statuses.values.where((s) => s.toLowerCase() == 'verified').length;

      if (mounted) {
        setState(() {
          _skillsWithStatus = statuses;
          _verifiedCount    = verifiedCount;
          _loadingSkills    = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSkills) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final hasVerifiedSkills = _verifiedCount > 0;
    final allSkills = _skillsWithStatus.entries.toList()
      ..sort((a, b) {
        if (a.value.toLowerCase() == 'verified' &&
            b.value.toLowerCase() != 'verified') return -1;
        if (a.value.toLowerCase() != 'verified' &&
            b.value.toLowerCase() == 'verified') return 1;
        return 0;
      });

    final visibleSkills = allSkills.take(3).toList();
    final extraCount    = allSkills.length - visibleSkills.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: (widget.seeker.logoUrl != null &&
                          widget.seeker.logoUrl!.isNotEmpty)
                      ? Image.network(
                          widget.seeker.logoUrl!,
                          width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/avatar.png',
                              width: 40, height: 40, fit: BoxFit.cover),
                        )
                      : Image.asset('assets/avatar.png',
                          width: 40, height: 40, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.seeker.isNameVisible
                          ? '${widget.seeker.firstName} ${widget.seeker.lastName}'
                          : 'Anonymous Candidate',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.seeker.desiredPosition,
                      style: const TextStyle(
                          color: AppColors.darkGreen, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasVerifiedSkills)
                const Icon(Icons.verified, color: Colors.green),
            ],
          ),

          const SizedBox(height: 10),

          // ── City ────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(widget.seeker.city,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Skill chips ─────────────────────────────────────
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              ...visibleSkills.map((entry) {
                final isVerified = entry.value.toLowerCase() == 'verified';
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? AppColors.lightgreen.withOpacity(0.15)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 140),
                        child: Text(entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11)),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 12, color: Colors.green),
                      ],
                    ],
                  ),
                );
              }),
              if (extraCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('+$extraCount more',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen)),
                ),
            ],
          ),

          if (widget.seeker.experienceDetails != null) ...[
            const SizedBox(height: 12),
            Text(widget.seeker.experienceDetails!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
          ],

          const SizedBox(height: 14),

          // ── Action buttons ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final auth = context.read<AuthProvider>();
                          if (auth.user == null) return;
                          setState(() => _loading = true);
                          try {
                            await _profileViewsRepo.saveUniqueDailyView(
                              userId:   widget.seeker.userId,
                              viewerId: auth.user!.userId,
                            );
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobSeekerDetailScreen(
                                    seeker: widget.seeker),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('View Profile'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.user == null) return;
                    final chatId = await ChatService().getOrCreateChat(
                      auth.user!.userId,
                      widget.seeker.userId,
                    );
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId:      chatId,
                          otherUserId: widget.seeker.userId,
                          personName:  widget.seeker.isNameVisible
                              ? '${widget.seeker.firstName} ${widget.seeker.lastName}'
                              : 'Anonymous Candidate',
                        ),
                      ),
                    );
                  },
                  child: const Text('Chat'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  DASHBOARD HEADERS
// ─────────────────────────────────────────────────────────────────
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
    final profile = await _repo.getByUid(user.userId);
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    }
    return _HeaderLayout(
        pharmacyName: _profile?.pharmacyName, logoUrl: _profile?.logoUrl);
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
    final profile = await _repo.getByUid(user.userId);
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.all(16), child: LinearProgressIndicator());
    }
    return _HeaderLayout(
        pharmacyName: _profile?.pharmacyName, logoUrl: _profile?.logoUrl);
  }
}

class _HeaderLayout extends StatelessWidget {
  final String? pharmacyName;
  final String? logoUrl;
  const _HeaderLayout({this.pharmacyName, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Seeker Profiles',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (logoUrl != null && logoUrl!.isNotEmpty)
                        ? Image.network(logoUrl!,
                            width: 18, height: 18, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                                'assets/avatar.png', width: 18, height: 18))
                        : Image.asset('assets/avatar.png',
                            width: 18, height: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(pharmacyName ?? '—',
                      style: const TextStyle(
                          color: AppColors.darkGreen, fontSize: 13)),
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationScreen())),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.notifications_none,
                  color: AppColors.darkGreen),
            ),
          ),
        ],
      ),
    );
  }
}



import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/JobSeekers/SkillMetaRepository.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

// ═══════════════════════════════════════════════════════════════════
//  FILTER MODEL
// ═══════════════════════════════════════════════════════════════════
class MapFilterResult {
  final String? wilaya;
  final String? district;
  final List<String> jobTitleIds;
  final List<String> jobTypes;
  final String? experienceLevel;

  const MapFilterResult({
    this.wilaya,
    this.district,
    this.jobTitleIds = const [],
    this.jobTypes = const [],
    this.experienceLevel,
  });

  bool get isEmpty =>
      wilaya == null &&
      district == null &&
      jobTitleIds.isEmpty &&
      jobTypes.isEmpty &&
      experienceLevel == null;

  int get activeCount {
    int n = 0;
    if (wilaya != null) n++;
    if (district != null) n++;
    if (jobTitleIds.isNotEmpty) n++;
    if (jobTypes.isNotEmpty) n++;
    if (experienceLevel != null) n++;
    return n;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PIN PAINTER  — Beautiful green Google Map style marker
// ═══════════════════════════════════════════════════════════════════
Future<Uint8List> _paintGooglePin({
  required String label,
  required bool selected,
}) async {
  const double dpr = 2.5;
  const double pinSize = 48;
  
  final shortened = label.length > 12 ? '${label.substring(0, 10)}…' : label;
  final tp = TextPainter(
    text: TextSpan(
      text: shortened,
      style: TextStyle(
        color: selected ? const Color(0xFF1A3C28) : Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();

  final double textW = tp.width;
  final double textH = tp.height;

  final double w = textW > pinSize ? textW + 16 : pinSize + 16;
  final double h = pinSize + textH + 4;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w * dpr, h * dpr));
  canvas.scale(dpr, dpr);

  final cx = w / 2;

  // 1) draw text first, lower down
  final labelX = cx - textW / 2;
  final labelY = pinSize - 6;

  // text outline
  final outlinePainter = TextPainter(
    text: TextSpan(
      text: shortened,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = Colors.white,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();
  outlinePainter.paint(canvas, Offset(labelX, labelY));
  tp.paint(canvas, Offset(labelX, labelY));

  // 2) draw pin icon
  final iconSp = TextSpan(
    text: String.fromCharCode(Icons.location_on.codePoint),
    style: TextStyle(
      fontSize: pinSize,
      fontFamily: Icons.location_on.fontFamily,
      package: Icons.location_on.fontPackage,
      color: selected ? const Color(0xFF3DBA6F) : const Color(0xFF2E7D52),
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
  );
  final ip = TextPainter(text: iconSp, textDirection: ui.TextDirection.ltr)..layout();
  final iconX = cx - ip.width / 2;
  ip.paint(canvas, Offset(iconX, 0));

  // 3) Draw a white dot inside the pin
  final circleY = pinSize * 0.36;
  canvas.drawCircle(
    Offset(cx, circleY),
    pinSize * 0.16,
    Paint()..color = Colors.white,
  );
  if (selected) {
    canvas.drawCircle(
      Offset(cx, circleY),
      pinSize * 0.08,
      Paint()..color = const Color(0xFF3DBA6F),
    );
  }

  final img = await recorder.endRecording().toImage((w * dpr).toInt(), (h * dpr).toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

// ═══════════════════════════════════════════════════════════════════
//  MAIN WIDGET
// ═══════════════════════════════════════════════════════════════════
class JobSeekerMapView extends StatefulWidget {
  final List<JobSeekerModel> seekers;
  final List<JobOption> allOptions;
  final String locale;

  const JobSeekerMapView({
    super.key,
    required this.seekers,
    required this.allOptions,
    required this.locale,
  });

  @override
  State<JobSeekerMapView> createState() => _JobSeekerMapViewState();
}

class _JobSeekerMapViewState extends State<JobSeekerMapView>
    with SingleTickerProviderStateMixin {
  // ── Map ──────────────────────────────────────────────────────────
  GoogleMapController? _ctrl;
  Set<Marker> _markers = {};
  bool _mapReady = false;

  // ── Selection ────────────────────────────────────────────────────
  JobSeekerModel? _selected;

  // ── Bottom sheet ─────────────────────────────────────────────────
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  // ── Filters ──────────────────────────────────────────────────────
  MapFilterResult _filter = const MapFilterResult();

  // ── Marker byte cache ────────────────────────────────────────────
  final Map<String, Uint8List> _cache = {};

  // ── Static data ──────────────────────────────────────────────────
  static const _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa',
    'Biskra', 'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa',
    'Tlemcen', 'Tiaret', 'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel',
    'Sétif', 'Saïda', 'Skikda', 'Sidi Bel Abbès', 'Annaba', 'Guelma',
    'Constantine', 'Médéa', 'Mostaganem', "M'Sila", 'Mascara', 'Ouargla',
    'Oran', 'El Bayadh', 'Illizi', 'Bordj Bou Arréridj', 'Boumerdès',
    'El Tarf', 'Tindouf', 'Tissemsilt', 'El Oued', 'Khenchela',
    'Souk Ahras', 'Tipaza', 'Mila', 'Ain Defla', 'Naâma',
    'Ain Témouchent', 'Ghardaïa', 'Relizane',
  ];

  static const _districts = <String, List<String>>{
    'Alger': [
      'Alger Centre', 'Bab El Oued', 'Kouba', 'Hussein Dey',
      'Bir Mourad Raïs', 'El Harrach', 'Bouzaréah', 'Chéraga', 'Hydra',
    ],
    'Oran': ['Oran Centre', 'Es Sénia', 'Bir El Djir', 'Arzew', 'Ain Turk'],
    'Constantine': [
      'Constantine Centre', 'El Khroub', 'Hamma Bouziane', 'Ain Smara',
    ],
    'Blida': ['Blida Centre', 'Boufarik', 'Meftah', 'Bougara'],
    'Annaba': ['Annaba Centre', 'El Bouni', 'Berrahal'],
  };

  static const _jobTypes = [
    'Full-time', 'Part-time', 'Temporary', 'Internship',
  ];

  static const _experienceLvls = [
    'Entry level', '1–3 years', '3–5 years', '5+ years',
  ];

  static const _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#f0f4f0"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#5a7a65"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#f0f4f0"}]},
    {"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
    {"featureType":"road.arterial","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#e8ede8"}]},
    {"featureType":"road.highway","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"road.local","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#c8e6d4"}]},
    {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#e8f0e8"}]}
  ]''';

  // ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant JobSeekerMapView old) {
    super.didUpdateWidget(old);
    if (old.seekers != widget.seekers && _mapReady) _buildMarkers();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _ctrl?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  //  Safe sheet animation — guards against not-yet-attached controller
  // ─────────────────────────────────────────────────────────────────
  void _safeAnimateSheet(double size,
      {Duration duration = const Duration(milliseconds: 380)}) {
    if (!_sheetCtrl.isAttached) return;
    _sheetCtrl.animateTo(
      size,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Filtered list
  // ─────────────────────────────────────────────────────────────────
  List<JobSeekerModel> get _visible {
    return widget.seekers.where((s) {
      if (s.latitude == 0.0 && s.longitude == 0.0) return false;
      if (_filter.wilaya != null) {
        final wi = _filter.wilaya!.toLowerCase();
        if (!s.city.toLowerCase().contains(wi) &&
            !s.streetAddress.toLowerCase().contains(wi)) return false;
      }
      if (_filter.district != null) {
        final di = _filter.district!.toLowerCase();
        if (!s.city.toLowerCase().contains(di) &&
            !s.streetAddress.toLowerCase().contains(di)) return false;
      }
      if (_filter.jobTitleIds.isNotEmpty) {
        final match = _filter.jobTitleIds.any((id) {
          final opt = _optionById(id);
          return opt != null &&
              s.desiredPosition.toLowerCase() == opt.en.toLowerCase();
        });
        if (!match) return false;
      }
      if (_filter.jobTypes.isNotEmpty) {
        final jt = _field(s, 'jobType');
        if (jt != null && !_filter.jobTypes.contains(jt)) return false;
      }
      if (_filter.experienceLevel != null) {
        final exp = _field(s, 'experienceLevel');
        if (exp != null && exp != _filter.experienceLevel) return false;
      }
      return true;
    }).toList();
  }

  String? _field(JobSeekerModel s, String key) {
    try {
      return (s.toMap())[key] as String?;
    } catch (_) {
      return null;
    }
  }

  JobOption? _optionById(String id) {
    try {
      return widget.allOptions.firstWhere((o) => o.docId == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Build / refresh all markers
  // ─────────────────────────────────────────────────────────────────
  Future<void> _buildMarkers() async {
    final list = _visible;
    final Set<Marker> result = {};

    for (final s in list) {
      final isSel = _selected?.userId == s.userId;
      final key = '${s.userId}_${isSel ? 'sel' : 'def'}';

      if (!_cache.containsKey(key)) {
        _cache[key] = await _paintGooglePin(
          label: s.desiredPosition,
          selected: isSel,
        );
      }

      result.add(
        Marker(
          markerId: MarkerId(s.userId),
          position: LatLng(s.latitude, s.longitude),
          icon: BitmapDescriptor.fromBytes(_cache[key]!),
          zIndex: isSel ? 10 : 1,
          anchor: const Offset(0.5, 0.70),
          onTap: () => _onPin(s),
        ),
      );
    }

    if (mounted) setState(() => _markers = result);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Pin tap
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onPin(JobSeekerModel s) async {
    final same = _selected?.userId == s.userId;

    if (_selected != null) {
      _cache
        ..remove('${_selected!.userId}_sel')
        ..remove('${_selected!.userId}_def');
    }

    if (same) {
      setState(() => _selected = null);
      _safeAnimateSheet(0.30);
    } else {
      _cache
        ..remove('${s.userId}_sel')
        ..remove('${s.userId}_def');
      setState(() => _selected = s);
      _ctrl?.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(s.latitude - 0.008, s.longitude), 14),
      );
      _safeAnimateSheet(0.52);
    }
    _buildMarkers();
  }

  // ─────────────────────────────────────────────────────────────────
  //  Dismiss selected
  // ─────────────────────────────────────────────────────────────────
  void _dismissSelected() {
    if (_selected == null) return;
    final id = _selected!.userId;
    setState(() => _selected = null);
    _cache
      ..remove('${id}_sel')
      ..remove('${id}_def');
    _buildMarkers();
    _safeAnimateSheet(0.30);
  }

  void _onMapTap(LatLng _) => _dismissSelected();

  // ─────────────────────────────────────────────────────────────────
  //  Filter sheet
  // ─────────────────────────────────────────────────────────────────
  Future<void> _openFilter() async {
    final res = await showModalBottomSheet<MapFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
        initial: _filter,
        allOptions: widget.allOptions,
        locale: widget.locale,
        wilayas: _wilayas,
        districts: _districts,
        jobTypes: _jobTypes,
        experienceLevels: _experienceLvls,
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _filter = res;
        _selected = null;
      });
      _cache.clear();
      _buildMarkers();
      _safeAnimateSheet(0.30,
          duration: const Duration(milliseconds: 320));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Stack(
      children: [
        // ── Google Map ───────────────────────────────────────────
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(36.737, 3.086),
            zoom: 10,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (ctrl) async {
            _ctrl = ctrl;
            _mapReady = true;
            await ctrl.setMapStyle(_mapStyle);
            _buildMarkers();
          },
          onTap: _onMapTap,
        ),

        // ── Top filter bar ───────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _TopBar(
              filter: _filter,
              count: list.length,
              onFilter: _openFilter,
              onClear: () {
                setState(() {
                  _filter = const MapFilterResult();
                  _selected = null;
                });
                _cache.clear();
                _buildMarkers();
                _safeAnimateSheet(0.30,
                    duration: const Duration(milliseconds: 320));
              },
            ),
          ),
        ),

        // ── Draggable Bottom Sheet ───────────────────────────────
        DraggableScrollableSheet(
          controller: _sheetCtrl,
          initialChildSize: 0.30,
          minChildSize: 0.14,
          maxChildSize: 0.88,
          snap: true,
          snapSizes: const [0.14, 0.30, 0.52, 0.88],
          builder: (context, scrollCtrl) {
            return _BottomSheet(
              scrollController: scrollCtrl,
              selected: _selected,
              seekers: list,
              allOptions: widget.allOptions,
              locale: widget.locale,
              onClose: _dismissSelected,
              onSeekerTap: _onPin,
            );
          },
        ),

        // ── "No location" hint ───────────────────────────────────
        if (list.isEmpty && widget.seekers.isNotEmpty && _mapReady)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_rounded,
                          color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No profiles have shared their location yet',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final JobSeekerModel? selected;
  final List<JobSeekerModel> seekers;
  final List<JobOption> allOptions;
  final String locale;
  final VoidCallback onClose;
  final ValueChanged<JobSeekerModel> onSeekerTap;

  const _BottomSheet({
    required this.scrollController,
    required this.selected,
    required this.seekers,
    required this.allOptions,
    required this.locale,
    required this.onClose,
    required this.onSeekerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 8),
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: [
                if (selected != null) ...[
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: Color(0xFF1A3C28),
                      ),
                    ),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const Spacer(),
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${seekers.length} profile${seekers.length == 1 ? '' : 's'} on map',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap a pin or scroll below',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3C28), Color(0xFF2E7D52)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${seekers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // Content — FIX: detail view uses its own scroll controller,
          // only the list uses the sheet-provided scrollController.
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: selected != null
                  ? KeyedSubtree(
                      key: ValueKey('detail_${selected!.userId}'),
                      // ← own independent ScrollController; no sheet controller here
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: _SeekerDetailCard(seeker: selected!),
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('list'),
                      child: seekers.isEmpty
                          ? _EmptyState(
                              scrollController: scrollController)
                          : ListView.builder(
                              // ← sheet-linked controller stays on the list
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(
                                  16, 10, 16, 24),
                              itemCount: seekers.length,
                              itemBuilder: (_, i) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: _SeekerListTile(
                                  seeker: seekers[i],
                                  onTap: () => onSeekerTap(seekers[i]),
                                ),
                              ),
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SEEKER LIST TILE
// ═══════════════════════════════════════════════════════════════════
class _SeekerListTile extends StatelessWidget {
  final JobSeekerModel seeker;
  final VoidCallback onTap;
  const _SeekerListTile({required this.seeker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = seeker.isNameVisible
        ? '${seeker.firstName} ${seeker.lastName}'
        : 'Anonymous Candidate';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _SmallAvatar(seeker: seeker, name: name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    seeker.desiredPosition,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D52),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          seeker.city,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (seeker.skills.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: seeker.skills
                          .take(3)
                          .map(
                            (sk) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3C28)
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                sk,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A3C28),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3C28).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF1A3C28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SEEKER DETAIL CARD
// ═══════════════════════════════════════════════════════════════════
class _SeekerDetailCard extends StatefulWidget {
  final JobSeekerModel seeker;
  const _SeekerDetailCard({required this.seeker});

  @override
  State<_SeekerDetailCard> createState() => _SeekerDetailCardState();
}

class _SeekerDetailCardState extends State<_SeekerDetailCard> {
  final _skillRepo = SkillMetaRepository();
  final _pvRepo = ProfileViewsRepository();

  StreamSubscription? _sub;
  Map<String, String> _statuses = {};
  bool _loadingMeta = true;
  bool _viewLoading = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant _SeekerDetailCard old) {
    super.didUpdateWidget(old);
    if (old.seeker.userId != widget.seeker.userId) {
      _sub?.cancel();
      setState(() {
        _statuses = {};
        _loadingMeta = true;
      });
      _listen();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _listen() {
    _sub = _skillRepo.collection
        .where('jobSeekerId', isEqualTo: widget.seeker.userId)
        .snapshots()
        .listen((snap) {
      final metas = snap.docs
          .map((d) => SkillVerificationMeta.fromMap(
                d.data() as Map<String, dynamic>,
                d.id,
              ))
          .toList();
      final Map<String, String> m = {};
      for (final skill in widget.seeker.skills) {
        final meta = metas.firstWhere(
          (x) => x.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: widget.seeker.userId,
            skill: skill,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        m[skill] = meta.status;
      }
      if (mounted) {
        setState(() {
          _statuses = m;
          _loadingMeta = false;
        });
      }
    });
  }

  int get _verified =>
      _statuses.values.where((v) => v.toLowerCase() == 'verified').length;

  @override
  Widget build(BuildContext context) {
    final s = widget.seeker;
    final name = s.isNameVisible
        ? '${s.firstName} ${s.lastName}'
        : 'Anonymous Candidate';

    final sorted = _statuses.entries.toList()
      ..sort((a, b) {
        final av = a.value.toLowerCase() == 'verified' ? 0 : 1;
        final bv = b.value.toLowerCase() == 'verified' ? 0 : 1;
        return av.compareTo(bv);
      });
    final show = sorted.take(6).toList();
    final extra = sorted.length - show.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile hero
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A3C28).withOpacity(0.05),
                const Color(0xFF2E7D52).withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF2E7D52).withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(seeker: s, name: name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_verified > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 12,
                                    color: Colors.green.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '$_verified verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.desiredPosition,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D52),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s.city,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Skills
        const Text(
          'Skills',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),

        if (_loadingMeta)
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          )
        else if (show.isEmpty)
          Text(
            'No skills listed',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...show.map((e) {
                final v = e.value.toLowerCase() == 'verified';
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        v ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: v
                        ? Border.all(
                            color: Colors.green.shade200, width: 0.8)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: v
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      if (v) ...[
                        const SizedBox(width: 3),
                        Icon(Icons.verified_rounded,
                            size: 11, color: Colors.green.shade500),
                      ],
                    ],
                  ),
                );
              }),
              if (extra > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$extra more',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3C28),
                    ),
                  ),
                ),
            ],
          ),

        // Experience
        if (s.experienceDetails?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          const Text(
            'Experience',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.experienceDetails!,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  if (auth.user == null) return;
                  final id = await ChatService().getOrCreateChat(
                    auth.user!.userId,
                    s.userId,
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: id,
                        otherUserId: s.userId,
                        personName: name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 15),
                label: const Text('Chat'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  foregroundColor: const Color(0xFF111111),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _viewLoading
                    ? null
                    : () async {
                        final auth = context.read<AuthProvider>();
                        if (auth.user == null) return;
                        setState(() => _viewLoading = true);
                        try {
                          await _pvRepo.saveUniqueDailyView(
                            userId: s.userId,
                            viewerId: auth.user!.userId,
                          );
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobSeekerDetailScreen(seeker: s),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _viewLoading = false);
                          }
                        }
                      },
                icon: _viewLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_outline_rounded, size: 15),
                label: const Text('View Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3C28),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL AVATAR (list tile)
// ═══════════════════════════════════════════════════════════════════
class _SmallAvatar extends StatelessWidget {
  final JobSeekerModel seeker;
  final String name;
  const _SmallAvatar({required this.seeker, required this.name});

  String get _initials {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A3C28).withOpacity(0.08),
          border: Border.all(
            color: const Color(0xFF2E7D52).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: seeker.logoUrl?.isNotEmpty == true
              ? Image.network(
                  seeker.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialsText(_initials),
                )
              : _InitialsText(_initials),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  AVATAR (detail card)
// ═══════════════════════════════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final JobSeekerModel seeker;
  final String name;
  const _Avatar({required this.seeker, required this.name});

  String get _initials {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A3C28).withOpacity(0.08),
          border: Border.all(
            color: const Color(0xFF2E7D52).withOpacity(0.25),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: seeker.logoUrl?.isNotEmpty == true
              ? Image.network(
                  seeker.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _InitialsText(_initials, size: 20),
                )
              : _InitialsText(_initials, size: 20),
        ),
      );
}

class _InitialsText extends StatelessWidget {
  final String text;
  final double size;
  const _InitialsText(this.text, {this.size = 16});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A3C28),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final ScrollController scrollController;
  const _EmptyState({required this.scrollController});

  @override
  Widget build(BuildContext context) => ListView(
        controller: scrollController,
        children: [
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Icon(Icons.person_search_rounded,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No profiles match your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final MapFilterResult _f;
  final int count;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  const _TopBar({
    required MapFilterResult filter,
    required this.count,
    required this.onFilter,
    required this.onClear,
  }) : _f = filter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onFilter,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _f.isEmpty
                          ? Colors.grey.shade200
                          : const Color(0xFF1A3C28),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: _f.isEmpty
                            ? Colors.grey.shade500
                            : const Color(0xFF1A3C28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _f.isEmpty
                            ? Text(
                                'Filter profiles…',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14),
                              )
                            : _ActiveChips(filter: _f),
                      ),
                      if (_f.activeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C28),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_f.activeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (!_f.isEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      );
}

class _ActiveChips extends StatelessWidget {
  final MapFilterResult filter;
  const _ActiveChips({required this.filter});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (filter.wilaya != null) filter.wilaya!,
      if (filter.district != null) filter.district!,
      ...filter.jobTitleIds.take(1),
      ...filter.jobTypes.take(1),
      if (filter.experienceLevel != null) filter.experienceLevel!,
    ];
    final show = items.take(2).toList();
    final over = items.length - show.length;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...show.map((c) => _MiniChip(c)),
        if (over > 0) _MiniChip('+$over', muted: true),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final bool muted;
  const _MiniChip(this.label, {this.muted = false});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: muted
              ? Colors.grey.shade100
              : const Color(0xFF1A3C28).withOpacity(0.10),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted
                ? Colors.grey.shade500
                : const Color(0xFF1A3C28),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER SHEET
// ═══════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final MapFilterResult initial;
  final List<JobOption> allOptions;
  final String locale;
  final List<String> wilayas;
  final Map<String, List<String>> districts;
  final List<String> jobTypes;
  final List<String> experienceLevels;

  const _FilterSheet({
    required this.initial,
    required this.allOptions,
    required this.locale,
    required this.wilayas,
    required this.districts,
    required this.jobTypes,
    required this.experienceLevels,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _wilaya;
  late String? _district;
  late List<String> _jobTitleIds;
  late List<String> _jobTypes;
  late String? _experience;

  @override
  void initState() {
    super.initState();
    _wilaya = widget.initial.wilaya;
    _district = widget.initial.district;
    _jobTitleIds = List.from(widget.initial.jobTitleIds);
    _jobTypes = List.from(widget.initial.jobTypes);
    _experience = widget.initial.experienceLevel;
  }

  List<JobOption> get _titles => widget.allOptions
      .where((o) => o.isActive && o.type == JobOptionType.jobTitle)
      .toList();

  List<String> get _availableDistricts =>
      _wilaya != null ? (widget.districts[_wilaya] ?? []) : [];

  int get _count {
    int n = 0;
    if (_wilaya != null) n++;
    if (_district != null) n++;
    if (_jobTitleIds.isNotEmpty) n++;
    if (_jobTypes.isNotEmpty) n++;
    if (_experience != null) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                const Text(
                  'Filter profiles',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const Spacer(),
                if (_count > 0)
                  GestureDetector(
                    onTap: () => setState(() {
                      _wilaya = null;
                      _district = null;
                      _jobTitleIds = [];
                      _jobTypes = [];
                      _experience = null;
                    }),
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              children: [
                _Sec('Wilaya', Icons.map_outlined),
                const SizedBox(height: 10),
                _ChipGrid(
                  items: widget.wilayas,
                  selected: _wilaya == null ? [] : [_wilaya!],
                  multi: false,
                  searchable: true,
                  onChanged: (sel) => setState(() {
                    _wilaya = sel.isEmpty ? null : sel.first;
                    _district = null;
                  }),
                ),
                if (_availableDistricts.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _Sec('District', Icons.location_city_outlined),
                  const SizedBox(height: 10),
                  _ChipGrid(
                    items: _availableDistricts,
                    selected: _district == null ? [] : [_district!],
                    multi: false,
                    onChanged: (sel) => setState(
                      () => _district =
                          sel.isEmpty ? null : sel.first,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _Sec('Job Title', Icons.work_outline_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _titles.map((opt) {
                    final lbl = opt.label(widget.locale);
                    final id = opt.docId;
                    final sel =
                        id != null && _jobTitleIds.contains(id);
                    return _Chip(
                      label: lbl,
                      selected: sel,
                      onTap: () {
                        if (id == null) return;
                        setState(() {
                          if (sel) {
                            _jobTitleIds.remove(id);
                          } else {
                            _jobTitleIds.add(id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _Sec('Job Type', Icons.schedule_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.jobTypes.map((t) {
                    final sel = _jobTypes.contains(t);
                    return _Chip(
                      label: t,
                      selected: sel,
                      icon: _icon(t),
                      onTap: () => setState(() =>
                          sel ? _jobTypes.remove(t) : _jobTypes.add(t)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _Sec('Experience', Icons.bar_chart_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.experienceLevels.map((lv) {
                    final sel = _experience == lv;
                    return _Chip(
                      label: lv,
                      selected: sel,
                      onTap: () => setState(
                          () => _experience = sel ? null : lv),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            child: Row(
              children: [
                if (_count > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_count active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        MapFilterResult(
                          wilaya: _wilaya,
                          district: _district,
                          jobTitleIds: _jobTitleIds,
                          jobTypes: _jobTypes,
                          experienceLevel: _experience,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C28),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Show results',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
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

  IconData _icon(String t) => switch (t) {
        'Full-time' => Icons.access_time_filled_rounded,
        'Part-time' => Icons.timelapse_rounded,
        'Temporary' => Icons.event_rounded,
        'Internship' => Icons.school_outlined,
        _ => Icons.work_outline_rounded,
      };
}

class _Sec extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Sec(this.title, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1A3C28)),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
        ],
      );
}

class _ChipGrid extends StatefulWidget {
  final List<String> items;
  final List<String> selected;
  final bool multi;
  final bool searchable;
  final ValueChanged<List<String>> onChanged;

  const _ChipGrid({
    required this.items,
    required this.selected,
    required this.multi,
    required this.onChanged,
    this.searchable = false,
  });

  @override
  State<_ChipGrid> createState() => _ChipGridState();
}

class _ChipGridState extends State<_ChipGrid> {
  String _q = '';

  List<String> get _filtered => _q.isEmpty
      ? widget.items
      : widget.items
          .where((i) => i.toLowerCase().contains(_q.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.searchable && widget.items.length > 8) ...[
            TextField(
              onChanged: (v) => setState(() => _q = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search wilaya…',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF1A3C28)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filtered.map((item) {
              final sel = widget.selected.contains(item);
              return _Chip(
                label: item,
                selected: sel,
                onTap: () {
                  final next = List<String>.from(widget.selected);
                  if (widget.multi) {
                    sel ? next.remove(item) : next.add(item);
                  } else {
                    next.clear();
                    if (!sel) next.add(item);
                  }
                  widget.onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
              horizontal: icon != null ? 10 : 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1A3C28)
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1A3C28)
                  : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      );
}