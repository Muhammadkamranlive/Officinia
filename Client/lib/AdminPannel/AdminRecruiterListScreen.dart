// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/Recruiter/Chat/ChatScreen.dart';
// import 'package:client/Recruiter/RecruiterDetailPage.dart';

// import 'package:client/Server/Model/Recruiter.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:client/Server/Services/ChatService.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';

// import '../l10n/app_localizations.dart';

// class RecruitersListScreen extends StatefulWidget {
//   const RecruitersListScreen({super.key});

//   @override
//   State<RecruitersListScreen> createState() => _RecruitersListScreenState();
// }

// class _RecruitersListScreenState extends State<RecruitersListScreen> {
//   final RecruiterRepository    _repo         = RecruiterRepository();
//   final TextEditingController  _searchCtrl   = TextEditingController();
//   final ScrollController       _scrollCtrl   = ScrollController();

//   // ── Pagination state ───────────────────────────────────────────────────────
//   final List<Recruiter> _recruiters     = [];
//   DocumentSnapshot?     _lastDoc;
//   bool                  _loadingInitial = true;
//   bool                  _loadingMore    = false;
//   bool                  _hasMore        = true;

//   // ── Search (client-side on loaded pages) ──────────────────────────────────
//   String _searchQuery = '';

//   List<Recruiter> get _filtered {
//     if (_searchQuery.isEmpty) return _recruiters;
//     final q = _searchQuery.toLowerCase();
//     return _recruiters.where((r) {
//       return r.pharmacyName.toLowerCase().contains(q) ||
//           r.pharmacistFirstName.toLowerCase().contains(q) ||
//           r.pharmacistLastName.toLowerCase().contains(q) ||
//           r.city.toLowerCase().contains(q);
//     }).toList();
//   }

//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   void initState() {
//     super.initState();
//     _fetchPage(reset: true);

//     // Auto-load when user scrolls within 300px of the bottom
//     _scrollCtrl.addListener(() {
//       if (_scrollCtrl.position.pixels >=
//               _scrollCtrl.position.maxScrollExtent - 300 &&
//           !_loadingMore &&
//           _hasMore) {
//         _fetchPage();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     _scrollCtrl.dispose();
//     super.dispose();
//   }

//   // ── Core paginated fetch ───────────────────────────────────────────────────
//   Future<void> _fetchPage({bool reset = false}) async {
//     if (_loadingMore && !reset) return;

//     if (reset) {
//       setState(() {
//         _recruiters.clear();
//         _lastDoc        = null;
//         _hasMore        = true;
//         _loadingInitial = true;
//       });
//     }

//     setState(() => _loadingMore = true);

//     try {
//       final page = await _repo.getRecruitersPage(
//         lastDocument: reset ? null : _lastDoc,
//       );

//       if (!mounted) return;
//       setState(() {
//         _recruiters.addAll(page.recruiters);
//         _lastDoc        = page.lastDoc;
//         _hasMore        = page.hasMore;
//         _loadingInitial = false;
//         _loadingMore    = false;
//       });
//     } catch (_) {
//       if (mounted) {
//         setState(() {
//           _loadingInitial = false;
//           _loadingMore    = false;
//         });
//       }
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  BUILD
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     final size     = MediaQuery.of(context).size;
//     final maxWidth =
//         kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         title: Text(
//           AppLocalizations.of(context)!.recruiters,
//           style: const TextStyle(
//             color: AppColors.darkGreen,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Center(
//         child: SizedBox(
//           width: maxWidth,
//           child: Column(
//             children: [
//               // ── Search bar ───────────────────────────────────────────────
//               Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: kIsWeb ? 24.0 : 16.0,
//                   vertical: 16,
//                 ),
//                 child: TextField(
//                   controller: _searchCtrl,
//                   onChanged: (v) =>
//                       setState(() => _searchQuery = v.trim()),
//                   decoration: InputDecoration(
//                     hintText: AppLocalizations.of(context)!.searchHint,
//                     prefixIcon:
//                         const Icon(Icons.search, color: Colors.black),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 16, horizontal: 16),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: BorderSide(
//                           color: Colors.black.withOpacity(0.5),
//                           width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16),
//                       borderSide: const BorderSide(
//                           color: Colors.black, width: 2),
//                     ),
//                     hintStyle: TextStyle(
//                         color: Colors.grey[500],
//                         fontWeight: FontWeight.w500),
//                   ),
//                   style: const TextStyle(
//                       fontSize: 14, color: Colors.black87),
//                 ),
//               ),

//               // ── List / grid ──────────────────────────────────────────────
//               Expanded(child: _buildList(size)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  LIST / GRID
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildList(Size size) {
//     if (_loadingInitial) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final items = _filtered;

//     if (items.isEmpty && !_hasMore) {
//       return  Center(child: Text(AppLocalizations.of(context)!.noRecruitersFound));
//     }

//     final padding = EdgeInsets.symmetric(
//       horizontal: kIsWeb ? 24.0 : 16.0,
//       vertical: 8,
//     );

//     // Web 2-column grid
//     if (kIsWeb && size.width > 700) {
//       return _WebTwoColumnGrid(
//         recruiters:     items,
//         padding:        padding,
//         scrollCtrl:     _scrollCtrl,
//         loadingMore:    _loadingMore,
//         hasMore:        _hasMore,
//         loadedCount:    _recruiters.length,
//         onLoadMore:     () => _fetchPage(),
//       );
//     }

//     // Mobile list
//     return ListView.builder(
//       controller:  _scrollCtrl,
//       padding:     padding,
//       itemCount:   items.length + 1, // +1 for footer
//       itemBuilder: (_, index) {
//         if (index < items.length) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 14),
//             child: RecruiterCard(recruiter: items[index]),
//           );
//         }
//         // Footer
//         return _RecruiterListFooter(
//           loadingMore: _loadingMore,
//           hasMore:     _hasMore,
//           loadedCount: _recruiters.length,
//           onLoadMore:  () => _fetchPage(),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// //  FOOTER  — spinner / load-more button / end label
// // ─────────────────────────────────────────────────────────────────────────────
// class _RecruiterListFooter extends StatelessWidget {
//   final bool         loadingMore;
//   final bool         hasMore;
//   final int          loadedCount;
//   final VoidCallback onLoadMore;

//   const _RecruiterListFooter({
//     required this.loadingMore,
//     required this.hasMore,
//     required this.loadedCount,
//     required this.onLoadMore,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Loading spinner
//     if (loadingMore) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 34,
//               height: 34,
//               child: CircularProgressIndicator(
//                 color: AppColors.darkGreen,
//                 strokeWidth: 2.5,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               AppLocalizations.of(context)!.recruitersLoaded( loadedCount),
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // More pages — load-more button
//     if (hasMore) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(0, 4, 0, 28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               '$loadedCount ${AppLocalizations.of(context)!.recruitersLoaded(loadedCount)}',
//               style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
//             ),
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: onLoadMore,
//               child: Container(
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: AppColors.darkGreen.withOpacity(.4),
//                     width: 1.5,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColors.darkGreen.withOpacity(.07),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         color: AppColors.darkGreen.withOpacity(.08),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: AppColors.darkGreen,
//                         size: 20,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       AppLocalizations.of(context)!.loadMoreRecruiters,
//                       style: TextStyle(
//                         color: AppColors.darkGreen,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: .2,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // All loaded — end indicator
//     if (loadedCount == 0) return const SizedBox.shrink();

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 28),
//       child: Row(
//         children: [
//           Expanded(child: Divider(color: Colors.grey.shade200)),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: AppColors.darkGreen.withOpacity(.06),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                     color: AppColors.darkGreen.withOpacity(.15)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.check_circle_outline_rounded,
//                       size: 14, color: AppColors.darkGreen),
//                   const SizedBox(width: 6),
//                   Text(
//                     AppLocalizations.of(context)!.allRecruitersLoaded(  loadedCount),
//                     style: TextStyle(
//                       color: AppColors.darkGreen,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(child: Divider(color: Colors.grey.shade200)),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// //  WEB 2-COLUMN GRID  (pagination-aware)
// // ─────────────────────────────────────────────────────────────────────────────
// class _WebTwoColumnGrid extends StatelessWidget {
//   final List<Recruiter>  recruiters;
//   final EdgeInsets       padding;
//   final ScrollController scrollCtrl;
//   final bool             loadingMore;
//   final bool             hasMore;
//   final int              loadedCount;
//   final VoidCallback     onLoadMore;

//   const _WebTwoColumnGrid({
//     required this.recruiters,
//     required this.padding,
//     required this.scrollCtrl,
//     required this.loadingMore,
//     required this.hasMore,
//     required this.loadedCount,
//     required this.onLoadMore,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final rows = <List<Recruiter>>[];
//     for (var i = 0; i < recruiters.length; i += 2) {
//       rows.add(recruiters.sublist(
//           i, i + 2 > recruiters.length ? recruiters.length : i + 2));
//     }

//     return ListView.builder(
//       controller: scrollCtrl,
//       padding:    padding,
//       itemCount:  rows.length + 1, // +1 for footer
//       itemBuilder: (context, rowIndex) {
//         if (rowIndex < rows.length) {
//           final row = rows[rowIndex];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 14),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: RecruiterCard(recruiter: row[0])),
//                 const SizedBox(width: 14),
//                 row.length > 1
//                     ? Expanded(child: RecruiterCard(recruiter: row[1]))
//                     : const Expanded(child: SizedBox.shrink()),
//               ],
//             ),
//           );
//         }
//         return Padding(
//           padding: padding,
//           child: _RecruiterListFooter(
//             loadingMore: loadingMore,
//             hasMore:     hasMore,
//             loadedCount: loadedCount,
//             onLoadMore:  onLoadMore,
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// //  RECRUITER CARD  — unchanged from original
// // ─────────────────────────────────────────────────────────────────────────────
// class RecruiterCard extends StatefulWidget {
//   final Recruiter recruiter;

//   const RecruiterCard({super.key, required this.recruiter});

//   @override
//   State<RecruiterCard> createState() => _RecruiterCardState();
// }

// class _RecruiterCardState extends State<RecruiterCard> {
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: premiumShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 20,
//                 backgroundColor: Colors.teal.shade50,
//                 child: Text(
//                   widget.recruiter.pharmacistFirstName.isNotEmpty
//                       ? widget.recruiter.pharmacistFirstName[0]
//                           .toUpperCase()
//                       : "R",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal.shade700,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.recruiter.pharmacyName,
//                       style: const TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w600),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       "${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}",
//                       style: const TextStyle(
//                           color: AppColors.darkGreen, fontSize: 13),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: widget.recruiter.isActive
//                       ? Colors.green
//                       : Colors.red,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   widget.recruiter.isActive ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.unverified,
//                   style: const TextStyle(
//                       color: Colors.white, fontSize: 12),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // Location
//           Row(
//             children: [
//               const Icon(Icons.location_on, size: 16, color: Colors.grey),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: Text(
//                   "${widget.recruiter.city}, ${widget.recruiter.province}",
//                   style: const TextStyle(fontSize: 12),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 34),

//           // Actions
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: _loading
//                       ? null
//                       : () {
//                           setState(() => _loading = true);
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => RecruiterDetailPage(
//                                   recruiter: widget.recruiter),
//                             ),
//                           ).then((_) =>
//                               setState(() => _loading = false));
//                         },
//                   child: _loading
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : Text(AppLocalizations.of(context)!.viewProfile),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final auth = context.read<AuthProvider>();
//                     if (auth.user == null) return;
//                     final chatService = ChatService();
//                     final chatId = await chatService.getOrCreateChat(
//                       auth.user!.userId,
//                       widget.recruiter.userId,
//                     );
//                     if (!context.mounted) return;
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatScreen(
//                           chatId: chatId,
//                           otherUserId: widget.recruiter.userId,
//                           personName:
//                               "${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}",
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text(AppLocalizations.of(context)!.chat),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/RecruiterDetailPage.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

// ── design tokens ────────────────────────────────────────────────────────────
const _kGreen      = AppColors.greenCeladon;
const _kGreenLight = Color(0xFFE8F5EE);
const _kGreenMid   = AppColors.darkGreen;
const _kAmber      = Color(0xFFF59E0B);
const _kAmberLight = Color(0xFFFFF8E1);
const _kSurface    = Color(0xFFF7F8F6);
const _kCard       = Colors.white;
const _kBorder     = Color(0xFFECEEEB);
const _kTextPri    = Color(0xFF111C17);
const _kTextSec    = Color(0xFF6B7C72);
const _kRed        = Color(0xFFD93025);
const _kRedLight   = Color(0xFFFFF0EE);

List<BoxShadow> get _cardShadow => [
      BoxShadow(
        color: const Color(0xFF1A5C3A).withOpacity(.06),
        blurRadius: 18,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(.03),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ];

// ─────────────────────────────────────────────────────────────────────────────
class RecruitersListScreen extends StatefulWidget {
  const RecruitersListScreen({super.key});

  @override
  State<RecruitersListScreen> createState() => _RecruitersListScreenState();
}

class _RecruitersListScreenState extends State<RecruitersListScreen> {
  final RecruiterRepository   _repo       = RecruiterRepository();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController      _scrollCtrl = ScrollController();

  final List<Recruiter> _recruiters     = [];
  DocumentSnapshot?     _lastDoc;
  bool                  _loadingInitial = true;
  bool                  _loadingMore    = false;
  bool                  _hasMore        = true;
  String                _searchQuery    = '';

  List<Recruiter> get _filtered {
    if (_searchQuery.isEmpty) return _recruiters;
    final q = _searchQuery.toLowerCase();
    return _recruiters.where((r) =>
        r.pharmacyName.toLowerCase().contains(q) ||
        r.pharmacistFirstName.toLowerCase().contains(q) ||
        r.pharmacistLastName.toLowerCase().contains(q) ||
        r.city.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchPage(reset: true);
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
              _scrollCtrl.position.maxScrollExtent - 300 &&
          !_loadingMore && _hasMore) {
        _fetchPage();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPage({bool reset = false}) async {
    if (_loadingMore && !reset) return;
    if (reset) {
      setState(() {
        _recruiters.clear();
        _lastDoc        = null;
        _hasMore        = true;
        _loadingInitial = true;
      });
    }
    setState(() => _loadingMore = true);
    try {
      final page = await _repo.getRecruitersPage(
          lastDocument: reset ? null : _lastDoc);
      if (!mounted) return;
      setState(() {
        _recruiters.addAll(page.recruiters);
        _lastDoc        = page.lastDoc;
        _hasMore        = page.hasMore;
        _loadingInitial = false;
        _loadingMore    = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loadingInitial = false; _loadingMore = false; });
    }
  }

  // ── build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context)!;
    final size     = MediaQuery.of(context).size;
    final maxWidth = kIsWeb ? (size.width > 960 ? 900.0 : size.width) : size.width;

    return Scaffold(
      backgroundColor: _kSurface,
      // ── top bar ────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kGreen,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recruiters,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
            if (!_loadingInitial)
              Text(
                '${_recruiters.length} registered',
                style: TextStyle(
                  color: Colors.white.withOpacity(.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: _SearchBar(
            controller: _searchCtrl,
            hint: l10n.searchHint,
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
          ),
        ),
      ),

      body: Center(
        child: SizedBox(
          width: maxWidth,
          child: _loadingInitial
              ? _shimmerList()
              : _buildList(size, l10n),
        ),
      ),
    );
  }

  // ── shimmer placeholder ───────────────────────────────────────

  Widget _shimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ShimmerCard(),
      ),
    );
  }

  // ── main list ─────────────────────────────────────────────────

  Widget _buildList(Size size, AppLocalizations l10n) {
    final items = _filtered;

    if (items.isEmpty && !_hasMore) {
      return _emptyState(l10n);
    }

    final padding = EdgeInsets.fromLTRB(
      kIsWeb ? 24 : 16, 20, kIsWeb ? 24 : 16, 16);

    if (kIsWeb && size.width > 700) {
      return _WebGrid(
        recruiters:  items,
        padding:     padding,
        scrollCtrl:  _scrollCtrl,
        loadingMore: _loadingMore,
        hasMore:     _hasMore,
        loadedCount: _recruiters.length,
        onLoadMore:  () => _fetchPage(),
      );
    }

    return ListView.builder(
      controller:  _scrollCtrl,
      padding:     padding,
      itemCount:   items.length + 1,
      itemBuilder: (_, i) {
        if (i < items.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: RecruiterCard(recruiter: items[i]),
          );
        }
        return _Footer(
          loadingMore: _loadingMore,
          hasMore:     _hasMore,
          loadedCount: _recruiters.length,
          onLoadMore:  () => _fetchPage(),
        );
      },
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _kGreenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                color: _kGreen, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecruitersFound,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _kTextPri,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term',
            style: TextStyle(fontSize: 13, color: _kTextSec),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: _kTextPri,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: _kTextSec,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: _kGreen, size: 20),
            suffixIcon: const Icon(Icons.tune_rounded,
                color: _kTextSec, size: 18),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RECRUITER CARD  — completely redesigned
// ─────────────────────────────────────────────────────────────────────────────
class RecruiterCard extends StatefulWidget {
  final Recruiter recruiter;
  const RecruiterCard({super.key, required this.recruiter});

  @override
  State<RecruiterCard> createState() => _RecruiterCardState();
}

class _RecruiterCardState extends State<RecruiterCard> {
  bool _navigating = false;

  Recruiter get r => widget.recruiter;

  // status helpers
  Color get _accentColor => r.isActive ? _kGreen : _kRed;
  Color get _accentLight => r.isActive ? _kGreenLight : _kRedLight;
  bool  get _isPro       => r.profileStatus == 'Pro';

  // initials from pharmacy name
  String get _initials {
    final words = r.pharmacyName.trim().split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return 'P';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _cardShadow,
        // left accent border encodes verified/unverified instantly
        border: Border(
          left: BorderSide(color: _accentColor, width: 4),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── top row: avatar + info + badges ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accentLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: r.logoUrl != null && r.logoUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              r.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _initialsWidget(),
                            ),
                          )
                        : _initialsWidget(),
                  ),
                  const SizedBox(width: 12),

                  // name block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                r.pharmacyName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _kTextPri,
                                  letterSpacing: -.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isPro) _proBadge(),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${r.pharmacistFirstName} ${r.pharmacistLastName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kTextSec,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // status + location row
                        Row(
                          children: [
                            _statusPill(l10n),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: _kTextSec),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${r.city}, ${r.province}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kTextSec,
                                ),
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

            // ── quota mini bar ─────────────────────────────────────
            if (r.jobPostLimit > 0) ...[
              const SizedBox(height: 14),
              _QuotaMiniBar(recruiter: r),
            ],

            // ── divider ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Divider(height: 1, color: _kBorder),
            ),

            // ── action buttons ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  // view profile
                  Expanded(
                    child: _ActionButton(
                      label: l10n.viewProfile,
                      icon: Icons.person_outline_rounded,
                      outlined: true,
                      loading: _navigating,
                      onTap: () async {
                        setState(() => _navigating = true);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecruiterDetailPage(recruiter: r),
                          ),
                        );
                        if (mounted) setState(() => _navigating = false);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // chat
                  Expanded(
                    child: _ActionButton(
                      label: l10n.chat,
                      icon: Icons.chat_bubble_outline_rounded,
                      outlined: false,
                      loading: false,
                      onTap: () async {
                        final auth = context.read<AuthProvider>();
                        if (auth.user == null) return;
                        final chatId = await ChatService().getOrCreateChat(
                          auth.user!.userId, r.userId);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              otherUserId: r.userId,
                              personName:
                                  '${r.pharmacistFirstName} ${r.pharmacistLastName}',
                            ),
                          ),
                        );
                      },
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

  Widget _initialsWidget() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _accentColor,
        ),
      ),
    );
  }

  Widget _statusPill(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _accentLight,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            r.isActive ? l10n.verified : l10n.unverified,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _kAmberLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kAmber.withOpacity(.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.workspace_premium_rounded,
              size: 11, color: _kAmber),
          SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _kAmber,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUOTA MINI BAR  — shows monthly usage at a glance on the card
// ─────────────────────────────────────────────────────────────────────────────
class _QuotaMiniBar extends StatelessWidget {
  final Recruiter recruiter;
  const _QuotaMiniBar({required this.recruiter});

  @override
  Widget build(BuildContext context) {
    final used  = recruiter.effectivePostCount;
    final limit = recruiter.jobPostLimit;
    final pct   = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    final Color barColor = pct >= 1.0
        ? _kRed
        : pct >= 0.8
            ? const Color(0xFFF59E0B)
            : _kGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded, size: 13, color: _kTextSec),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: _kBorder,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$used/$limit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     outlined;
  final bool     loading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.outlined,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: _kGreen),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: outlined ? _kGreen : Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: outlined ? _kGreen : Colors.white,
                ),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: loading ? null : onTap,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kGreen, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11)),
            padding: EdgeInsets.zero,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11)),
          padding: EdgeInsets.zero,
        ),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FOOTER
// ─────────────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final bool         loadingMore;
  final bool         hasMore;
  final int          loadedCount;
  final VoidCallback onLoadMore;

  const _Footer({
    required this.loadingMore,
    required this.hasMore,
    required this.loadedCount,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: _kGreen, strokeWidth: 2.5),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.recruitersLoaded(loadedCount),
              style: const TextStyle(
                  fontSize: 12, color: _kTextSec),
            ),
          ],
        ),
      );
    }

    if (hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.recruitersLoaded(loadedCount),
              style: const TextStyle(
                  fontSize: 12, color: _kTextSec),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onLoadMore,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _kGreen.withOpacity(.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withOpacity(.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _kGreenLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _kGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.loadMoreRecruiters,
                      style: const TextStyle(
                        color: _kGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (loadedCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kGreenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 13, color: _kGreen),
                  const SizedBox(width: 5),
                  Text(
                    l10n.allRecruitersLoaded(loadedCount),
                    style: const TextStyle(
                      color: _kGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHIMMER PLACEHOLDER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween(begin: .3, end: .7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer = Color.lerp(
            const Color(0xFFECEEEB), const Color(0xFFD8DBD7), _anim.value)!;

        return Container(
          height: 148,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(color: shimmer, width: 4),
            ),
            boxShadow: _cardShadow,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 14, width: 140,
                            decoration: BoxDecoration(
                              color: shimmer,
                              borderRadius: BorderRadius.circular(4),
                            )),
                        const SizedBox(height: 8),
                        Container(height: 10, width: 100,
                            decoration: BoxDecoration(
                              color: shimmer,
                              borderRadius: BorderRadius.circular(4),
                            )),
                        const SizedBox(height: 8),
                        Container(height: 18, width: 80,
                            decoration: BoxDecoration(
                              color: shimmer,
                              borderRadius: BorderRadius.circular(99),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 36,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(11),
                        )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(height: 36,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(11),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WEB 2-COLUMN GRID — unchanged logic
// ─────────────────────────────────────────────────────────────────────────────
class _WebGrid extends StatelessWidget {
  final List<Recruiter>  recruiters;
  final EdgeInsets       padding;
  final ScrollController scrollCtrl;
  final bool             loadingMore;
  final bool             hasMore;
  final int              loadedCount;
  final VoidCallback     onLoadMore;

  const _WebGrid({
    required this.recruiters,
    required this.padding,
    required this.scrollCtrl,
    required this.loadingMore,
    required this.hasMore,
    required this.loadedCount,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<Recruiter>>[];
    for (var i = 0; i < recruiters.length; i += 2) {
      rows.add(recruiters.sublist(
          i, i + 2 > recruiters.length ? recruiters.length : i + 2));
    }

    return ListView.builder(
      controller: scrollCtrl,
      padding:    padding,
      itemCount:  rows.length + 1,
      itemBuilder: (_, rowIndex) {
        if (rowIndex < rows.length) {
          final row = rows[rowIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RecruiterCard(recruiter: row[0])),
                const SizedBox(width: 14),
                row.length > 1
                    ? Expanded(child: RecruiterCard(recruiter: row[1]))
                    : const Expanded(child: SizedBox.shrink()),
              ],
            ),
          );
        }
        return _Footer(
          loadingMore: loadingMore,
          hasMore:     hasMore,
          loadedCount: loadedCount,
          onLoadMore:  onLoadMore,
        );
      },
    );
  }
}