// import 'package:client/AppColors/AppColors.dart';
// import 'package:client/Server/Model/JobOffer.dart';
// import 'package:client/Server/Model/Recruiter.dart';
// import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:client/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';

// class RecruiterDetailPage extends StatefulWidget {
//   final Recruiter recruiter;
   
//   const RecruiterDetailPage({super.key, required this.recruiter});

//   @override
//   State<RecruiterDetailPage> createState() => _RecruiterDetailPageState();
// }

// class _RecruiterDetailPageState extends State<RecruiterDetailPage> {
//   late bool isActive;
//   final JobOfferRepository _jobRepo = JobOfferRepository();

 

// String _formatDate(DateTime date) {
//   return "${date.day.toString().padLeft(2, '0')} "
//       "${_month(date.month)} ${date.year} • "
//       "${date.hour % 12 == 0 ? 12 : date.hour % 12}:"
//       "${date.minute.toString().padLeft(2, '0')} "
//       "${date.hour >= 12 ? 'PM' : 'AM'}";
// }

// String _month(int m) {
//   const months = [
//     "Jan","Feb","Mar","Apr","May","Jun",
//     "Jul","Aug","Sep","Oct","Nov","Dec"
//   ];
//   return months[m - 1];
// }

//  @override
// void initState() {
//   super.initState();
//   isActive = widget.recruiter.isActive;
  
// }

//   @override
//   Widget build(BuildContext context) {
//     final r = widget.recruiter;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         iconTheme: const IconThemeData(color: AppColors.darkGreen),
//         title:  Text(
//           AppLocalizations.of(context)!.recruiterProfile,
//           style: TextStyle(
//             color: AppColors.darkGreen,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// Header Card
//             _headerCard(r),

//             const SizedBox(height: 16),

//             _infoCard(
//               title: AppLocalizations.of(context)!.pharmacyInfo,
//               children: [
//                 _infoRow(AppLocalizations.of(context)!.pharmacyName, r.pharmacyName),
//                 _infoRow(AppLocalizations.of(context)!.address, r.streetAddress),
//                 _infoRow(AppLocalizations.of(context)!.province, r.province),
//                 _infoRow(AppLocalizations.of(context)!.location_label, r.city),
//               ],
//             ),

//             const SizedBox(height: 16),

//             _infoCard(
//               title: AppLocalizations.of(context)!.pharmacyName,
//               children: [
//                 _infoRow(AppLocalizations.of(context)!.firstName, r.pharmacistFirstName),
//                 _infoRow(AppLocalizations.of(context)!.lastName, r.pharmacistLastName),
//               ],
//             ),

//             const SizedBox(height: 16),

//             _infoCard(
//               title: AppLocalizations.of(context)!.metaInfo,
//               children: [
//                 _infoRow(AppLocalizations.of(context)!.userId, r.userId),
//                 _infoRow(AppLocalizations.of(context)!.createdAt, _formatDate(r.createdAt)),
//                 _infoRow(AppLocalizations.of(context)!.latitude, r.latitude.toString()),
//                 _infoRow(AppLocalizations.of(context)!.longitude, r.longitude.toString()),
//               ],
//             ),

//             const SizedBox(height: 16),
//             _jobsCard(),

//             const SizedBox(height: 16),

//             // ── Admin: quota management ────────────────────────────────
//             _quotaCard(),

//             const SizedBox(height: 24),
            

//             /// Action Button
//             _statusActionButton(),
//             if (isActive && widget.recruiter.profileStatus != "Pro") ...[
//   const SizedBox(height: 12),
//   _makeProButton(),
// ],

//           ],
//         ),
//       ),
//     );
//   }


//   Widget _quotaCard() {
//   final r = widget.recruiter;
//   final int limit = r.jobPostLimit;
//   final int used = r.effectivePostCount;
//   final int remaining = r.remainingPostsThisMonth;
//   final double pct = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

//   // reset date: 1st of next month
//   final now = DateTime.now();
//   final resetDate = DateTime(now.year, now.month + 1, 1);
//   final resetStr = "${resetDate.day.toString().padLeft(2,'0')} "
//       "${_month(resetDate.month)} ${resetDate.year}";

//   Color barColor = Colors.green.shade600;
//   if (pct >= 1.0) barColor = Colors.red.shade600;
//   else if (pct >= 0.8) barColor = Colors.orange.shade600;

//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.04),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Monthly job post quota',
//           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 14),

//         // ── Stats rows ──────────────────────────────────────────
//         _quotaRow('Current limit', '$limit posts / month'),
//         _quotaRow('Used this month', '$used posts'),

//         // progress bar row
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Text('Remaining',
//                         style: TextStyle(fontSize: 13, color: Colors.black54)),
//                   ),
//                   Text(
//                     '$remaining left',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: barColor,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(99),
//                 child: LinearProgressIndicator(
//                   value: pct,
//                   minHeight: 6,
//                   backgroundColor: Colors.grey.shade100,
//                   valueColor: AlwaysStoppedAnimation<Color>(barColor),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         _quotaRow('Resets on', resetStr),
//         _quotaRow(
//           'Status',
//           pct >= 1.0 ? 'Limit reached' : 'Under limit',
//           valueColor: pct >= 1.0 ? Colors.red.shade700 : Colors.green.shade700,
//         ),

//         const Divider(height: 28, thickness: 0.8),

//         // ── Admin controls ──────────────────────────────────────
//         const Text(
//           'ADMIN — ADJUST LIMIT',
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: Colors.black45,
//             letterSpacing: 0.8,
//           ),
//         ),
//         const SizedBox(height: 12),
//         _QuotaEditor(
//           currentLimit: limit,
//           recruiterDocId: r.docId!,
//           onSaved: (newLimit) {
//             // Optimistically update local UI
//             setState(() {
//               widget.recruiter.profileStatus = widget.recruiter.profileStatus; // trigger rebuild
//             });
//           },
//         ),
//       ],
//     ),
//   );
// }

// Widget _quotaRow(String label, String value, {Color? valueColor}) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(label,
//               style: const TextStyle(fontSize: 13, color: Colors.black54)),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: valueColor ?? Colors.black87,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _makeProButton() {
//   return SizedBox(
//     width: double.infinity,
//     height: 52,
//     child: ElevatedButton.icon(
//       icon: const Icon(Icons.workspace_premium, color: Colors.white),
//       label:  Text(
//        AppLocalizations.of(context)!.makeRecruiterPro,
//         style: TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//       ),
//       onPressed: _makeRecruiterPro,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.amber.shade700,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//     ),
//   );
// }

// void _makeRecruiterPro() async {
//   final repo = RecruiterRepository();

//   await repo.update1(widget.recruiter.docId!, {
//     'profileStatus': 'Pro',
//   });

//   ScaffoldMessenger.of(context).showSnackBar(
//      SnackBar(
//       content: Text(AppLocalizations.of(context)!.recruiterUpgraded),
//     ),
//   );

//   setState(() {
//     widget.recruiter.profileStatus = "Pro";
//   });
// }
// Widget _jobsCard() {
//   return FutureBuilder<List<JobOffer>>(
//     future: JobOfferRepository()
//         .getByUserId(widget.recruiter.userId), // 🔥 DIRECT CALL
//     builder: (context, snapshot) {
//       // 👇 NOW loading WILL trigger
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return _infoCard(
//           title: AppLocalizations.of(context)!.jobStats,
//           children: const [
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           ],
//         );
//       }

//       if (snapshot.hasError) {
//         return _infoCard(
//           title: AppLocalizations.of(context)!.jobStats,
//           children:  [
//             Text(
//               AppLocalizations.of(context)!.failedLoadJobs,
//               style: TextStyle(color: Colors.red),
//             ),
//           ],
//         );
//       }

//       final jobs = snapshot.data ?? [];

//       final total = jobs.length;
//       final active = jobs.where((j) => j.isActive && !j.isDraft).length;
//       final drafts = jobs.where((j) => j.isDraft).length;

//       return _infoCard(
//         title: AppLocalizations.of(context)!.jobStats,
//         children: [
//           _statRow(AppLocalizations.of(context)!.totalJobs, total),
//           _statRow(AppLocalizations.of(context)!.activeJobs, active),
//           _statRow(AppLocalizations.of(context)!.draftJobs, drafts),
//         ],
//       );
//     },
//   );
// }

// Widget _statRow(String label, int value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//         ),
//         Text(
//           value.toString(),
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//             color: AppColors.darkGreen,
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   // ================= ACTION =================

//   Widget _statusActionButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: _updateStatus,
//         style: ElevatedButton.styleFrom(
//           elevation: 4,
//           backgroundColor: isActive ? AppColors.red: AppColors.greenCeladon,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//         child: Text(
//           isActive ? AppLocalizations.of(context)!.unverifyRecruiter : AppLocalizations.of(context)!.verifyRecruiter,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   void _updateStatus() async {
//     RecruiterRepository recruiterRepository = RecruiterRepository();
//     setState(() => isActive = !isActive);

//     /// 🔥 Update model
//     final updatedRecruiter = Recruiter(
//       userId: widget.recruiter.userId,
//       pharmacyName: widget.recruiter.pharmacyName,
//       pharmacistFirstName: widget.recruiter.pharmacistFirstName,
//       pharmacistLastName: widget.recruiter.pharmacistLastName,
//       province: widget.recruiter.province,
//       city: widget.recruiter.city,
//       streetAddress: widget.recruiter.streetAddress,
//       latitude: widget.recruiter.latitude,
//       longitude: widget.recruiter.longitude,
//       createdAt: widget.recruiter.createdAt,
//       isActive: isActive, // ✅ new value
//       docId: widget.recruiter.docId,
//       logoUrl: widget.recruiter.logoUrl,

//     );

//     await recruiterRepository.update(widget.recruiter.docId!, updatedRecruiter);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           isActive
//               ? AppLocalizations.of(context)!.recruiterApproved
//               : AppLocalizations.of(context)!.recruiterDeactivated,
//         ),
//       ),
//     );
//   }

//   // ================= UI =================

//   Widget _headerCard(Recruiter r) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.darkGreen, AppColors.darkGreen.withOpacity(.8)],
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 28,
//             backgroundColor: Colors.white,
//             child: Text(
//               r.pharmacyName.isNotEmpty ? r.pharmacyName[0].toUpperCase() : "P",
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkGreen,
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   r.pharmacyName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "${r.pharmacistFirstName} ${r.pharmacistLastName}",
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ],
//             ),
//           ),
//           _statusBadge(),
//         ],
//       ),
//     );
//   }

//   Widget _statusBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: isActive ? Colors.green : Colors.red,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         isActive ? AppLocalizations.of(context)!.verified : AppLocalizations.of(context)!.unverified,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }

// Widget _infoCard({required String title, required List<Widget> children}) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(.04),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     ),
//   );
// }

// Widget _infoRow(String label, String value) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 6),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Colors.black54),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     ),
//   );
// }


// class _QuotaEditor extends StatefulWidget {
//   final int currentLimit;
//   final String recruiterDocId;
//   final void Function(int newLimit) onSaved;

//   const _QuotaEditor({
//     required this.currentLimit,
//     required this.recruiterDocId,
//     required this.onSaved,
//   });

//   @override
//   State<_QuotaEditor> createState() => _QuotaEditorState();
// }

// class _QuotaEditorState extends State<_QuotaEditor> {
//   late int _limit;
//   bool _saving = false;
//   final _repo = RecruiterRepository();

//   @override
//   void initState() {
//     super.initState();
//     _limit = widget.currentLimit;
//   }

//   void _adjust(int delta) =>
//       setState(() => _limit = (_limit + delta).clamp(1, 500));

//   Future<void> _save() async {
//     setState(() => _saving = true);
//     await _repo.setJobPostLimitForCurrentMonth(widget.recruiterDocId, _limit);
//     widget.onSaved(_limit);
//     setState(() => _saving = false);
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Job post limit updated to $_limit for this month.'),
//           backgroundColor: AppColors.darkGreen,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ── +/− buttons + number display ───────────────────────
//         Row(
//           children: [
//             _adjBtn('−10', () => _adjust(-10)),
//             const SizedBox(width: 6),
//             _adjBtn('−5', () => _adjust(-5)),
//             const SizedBox(width: 6),
//             _adjBtn('−1', () => _adjust(-1)),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.darkGreen.withOpacity(.07),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   '$_limit',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.darkGreen,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             _adjBtn('+1', () => _adjust(1)),
//             const SizedBox(width: 6),
//             _adjBtn('+5', () => _adjust(5)),
//             const SizedBox(width: 6),
//             _adjBtn('+10', () => _adjust(10)),
//           ],
//         ),
//         const SizedBox(height: 10),

//         // ── Action row ──────────────────────────────────────────
//         Row(
//           children: [
//             // reset to default
//             OutlinedButton(
//               onPressed: () => setState(() => _limit = 30),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 10),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text('Reset to 30',
//                   style: TextStyle(fontSize: 12)),
//             ),
//             const Spacer(),
//             // save
//             ElevatedButton(
//               onPressed: _saving ? null : _save,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.darkGreen,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 22, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//               ),
//               child: _saving
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2),
//                     )
//                   : const Text('Save limit',
//                       style: TextStyle(color: Colors.white, fontSize: 13)),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           _limit == 30
//               ? 'Next month this resets to 30 automatically.'
//               : 'Custom limit of $_limit is active for this month. Resets to 30 next month.',
//           style: const TextStyle(fontSize: 11, color: Colors.black38),
//         ),
//       ],
//     );
//   }

//   Widget _adjBtn(String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//               fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/NotificationService.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecruiterDetailPage extends StatefulWidget {
  final Recruiter recruiter;
  const RecruiterDetailPage({super.key, required this.recruiter});

  @override
  State<RecruiterDetailPage> createState() => _RecruiterDetailPageState();
}

class _RecruiterDetailPageState extends State<RecruiterDetailPage> {
  final _repo = RecruiterRepository();
  StreamSubscription<Recruiter?>? _sub;

  // live data — starts from the passed-in recruiter, updates via stream
  late Recruiter _r;
  bool _streamError = false;

  @override
  void initState() {
    super.initState();
    _r = widget.recruiter;
    _subscribeToRecruiter();
  }

  void _subscribeToRecruiter() {
    _sub = _repo.streamByUid(widget.recruiter.userId).listen(
      (updated) {
        if (updated != null && mounted) {
          setState(() {
            _r = updated;
            _streamError = false;
          });
        }
      },
      onError: (_) {
        if (mounted) setState(() => _streamError = true);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────

  String _formatDate(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day.toString().padLeft(2, '0')} ${_mon(d.month)} ${d.year}  $h:$min $ampm';
  }

  String _mon(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];

  // ── actions ──────────────────────────────────────────────────

  Future<void> _toggleStatus() async {
    final newActive = !_r.isActive;
    final updated = Recruiter(
      userId: _r.userId,
      pharmacyName: _r.pharmacyName,
      pharmacistFirstName: _r.pharmacistFirstName,
      pharmacistLastName: _r.pharmacistLastName,
      province: _r.province,
      city: _r.city,
      streetAddress: _r.streetAddress,
      latitude: _r.latitude,
      longitude: _r.longitude,
      createdAt: _r.createdAt,
      isActive: newActive,
      docId: _r.docId,
      logoUrl: _r.logoUrl,
      profileStatus: _r.profileStatus,
      licenseStatus: _r.licenseStatus,
      licenseExpiresAt: _r.licenseExpiresAt,
      jobPostLimit: _r.jobPostLimit,
      jobPostCount: _r.jobPostCount,
      jobPostMonth: _r.jobPostMonth,
    );
    await _repo.update(_r.docId!, updated);
    
    // Send localized notification to recruiter
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      NotificationService.sendToUser(
        targetUserId: _r.userId,
        type: newActive ? 'account_verified' : 'account_deactivated',
        title: newActive 
            ? l10n.notif_account_verified_title 
            : l10n.notif_account_deactivated_title,
        description: newActive 
            ? l10n.notif_account_verified_desc 
            : l10n.notif_account_deactivated_desc,
      );

      _showSnack(
        newActive
            ? l10n.recruiterApproved
            : l10n.recruiterDeactivated,
        newActive ? AppColors.darkGreen : Colors.red.shade700,
      );
    }
  }

  Future<void> _makePro() async {
    await _repo.update1(_r.docId!, {'profileStatus': 'Pro'});
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      NotificationService.sendToUser(
        targetUserId: _r.userId,
        type: 'account_pro',
        title: l10n.notif_account_pro_title,
        description: l10n.notif_account_pro_desc,
      );
      _showSnack(l10n.recruiterUpgraded, Colors.amber.shade700);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: CustomScrollView(
        slivers: [
          // ── collapsing hero app bar ────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.greenCeladon,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: _heroHeader(),
            ),
            title: Text(
              l10n.recruiterProfile,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // ── body content ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                children: [
                  if (_streamError)
                    _errorBanner(),

                  // status + pro badges row
                  _badgeRow(l10n),
                  const SizedBox(height: 20),

                  // info sections
                  _section(
                    icon: Icons.work_outline_rounded,
                    title: l10n.pharmacyInfo,
                    color: AppColors.darkGreen,
                    children: [
                      _row(l10n.pharmacyName, _r.pharmacyName),
                      _row(l10n.address, _r.streetAddress),
                      _row(l10n.province, _r.province),
                      _row(l10n.location_label, _r.city),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _section(
                    icon: Icons.person_outline_rounded,
                    title: l10n.pharmacyName, // "Pharmacist info"
                    color: const Color(0xFF2E7D9E),
                    children: [
                      _row(l10n.firstName, _r.pharmacistFirstName),
                      _row(l10n.lastName, _r.pharmacistLastName),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _section(
                    icon: Icons.info_outline_rounded,
                    title: l10n.metaInfo,
                    color: Colors.blueGrey.shade600,
                    children: [
                      _copyRow(l10n.userId, _r.userId),
                      _row(l10n.createdAt, _formatDate(_r.createdAt)),
                      _row(l10n.latitude, _r.latitude.toStringAsFixed(6)),
                      _row(l10n.longitude, _r.longitude.toStringAsFixed(6)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // job stats — stream-driven too
                  _jobStatsSection(l10n),
                  const SizedBox(height: 14),

                  // quota card — reads from live _r
                  _quotaSection(l10n),
                  const SizedBox(height: 28),

                  // action buttons
                  _actionButtons(l10n),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── hero header ───────────────────────────────────────────────

  Widget _heroHeader() {
    final initials = _r.pharmacyName.isNotEmpty
        ? _r.pharmacyName[0].toUpperCase()
        : 'P';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.greenCeladon,
            AppColors.greenCeladon.withOpacity(.75),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Row(
            children: [
              // avatar with logo or initials
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: (_r.logoUrl != null && _r.logoUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(_r.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (_r.logoUrl == null || _r.logoUrl!.isEmpty)
                    ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _r.pharmacyName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_r.pharmacistFirstName} ${_r.pharmacistLastName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.white60),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${_r.city}, ${_r.province}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  // ── badge row ─────────────────────────────────────────────────

  Widget _badgeRow(AppLocalizations l10n) {
    return Row(
      children: [
        _badge(
          icon: _r.isActive
              ? Icons.verified_rounded
              : Icons.cancel_outlined,
          label: _r.isActive ? l10n.verified : l10n.unverified,
          bg: _r.isActive
              ? const Color(0xFFE6F4EC)
              : const Color(0xFFFFEBEB),
          fg: _r.isActive
              ? const Color(0xFF1B6B3A)
              : const Color(0xFFC0392B),
        ),
        const SizedBox(width: 8),
        _badge(
          icon: _r.profileStatus == 'Pro'
              ? Icons.workspace_premium_rounded
              : Icons.person_outline_rounded,
          label: _r.profileStatus == 'Pro' ? 'Pro' : 'Standard',
          bg: _r.profileStatus == 'Pro'
              ? const Color(0xFFFFF8E1)
              : const Color(0xFFF0F0F0),
          fg: _r.profileStatus == 'Pro'
              ? const Color(0xFF8B6300)
              : Colors.black54,
        ),
        const SizedBox(width: 8),
        _badge(
          icon: _r.hasActiveLicense
              ? Icons.card_membership_rounded
              : Icons.block_rounded,
          label: _r.licenseStatus ?? 'No license',
          bg: _r.hasActiveLicense
              ? const Color(0xFFE8F4FD)
              : const Color(0xFFF5F5F5),
          fg: _r.hasActiveLicense
              ? const Color(0xFF1565C0)
              : Colors.black38,
        ),
        // live indicator
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EC),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B6B3A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Live',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B6B3A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  // ── section card ──────────────────────────────────────────────

  Widget _section({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // section header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ),
          Expanded(
            flex: 7,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                _showSnack('Copied!', AppColors.darkGreen);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade600,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.copy_rounded,
                      size: 13, color: Colors.blueGrey.shade400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── job stats ─────────────────────────────────────────────────

  Widget _jobStatsSection(AppLocalizations l10n) {
    return FutureBuilder<List<JobOffer>>(
      future: JobOfferRepository().getByUserId(_r.userId),
      builder: (context, snap) {
        final loading = snap.connectionState == ConnectionState.waiting;
        final jobs = snap.data ?? [];
        final total = jobs.length;
        final active = jobs.where((j) => j.isActive && !j.isDraft).length;
        final drafts = jobs.where((j) => j.isDraft).length;

        return _section(
          icon: Icons.work_outline_rounded,
          title: l10n.jobStats,
          color: const Color(0xFF5C6BC0),
          children: loading
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                ]
              : [
                  _statTile(
                    l10n.totalJobs,
                    total,
                    Icons.list_alt_rounded,
                    const Color(0xFF5C6BC0),
                  ),
                  _statTile(
                    l10n.activeJobs,
                    active,
                    Icons.check_circle_outline_rounded,
                    AppColors.darkGreen,
                  ),
                  _statTile(
                    l10n.draftJobs,
                    drafts,
                    Icons.drafts_outlined,
                    Colors.orange.shade700,
                  ),
                ],
        );
      },
    );
  }

  Widget _statTile(String label, int value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.withOpacity(.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── quota section ─────────────────────────────────────────────

  Widget _quotaSection(AppLocalizations l10n) {
    final int limit = _r.jobPostLimit;
    final int used = _r.effectivePostCount;
    final int remaining = _r.remainingPostsThisMonth;
    final double pct = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;

    final Color barColor = pct >= 1.0
        ? Colors.red.shade600
        : pct >= 0.8
            ? Colors.orange.shade600
            : AppColors.darkGreen;

    final now = DateTime.now();
    final reset = DateTime(now.year, now.month + 1, 1);
    final resetStr =
        '${reset.day.toString().padLeft(2, '0')} ${_mon(reset.month)} ${reset.year}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withOpacity(.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                bottom: BorderSide(
                    color: AppColors.darkGreen.withOpacity(.1), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.bar_chart_rounded,
                      size: 16, color: AppColors.darkGreen),
                ),
                const SizedBox(width: 10),
                Text(
                  'Monthly quota',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // big 3 metric tiles
                Row(
                  children: [
                    _metricTile('Limit', '$limit', AppColors.darkGreen),
                    const SizedBox(width: 10),
                    _metricTile('Used', '$used', barColor),
                    const SizedBox(width: 10),
                    _metricTile('Left', '$remaining', barColor),
                  ],
                ),
                const SizedBox(height: 16),

                // progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(barColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(pct * 100).round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pct >= 1.0 ? 'Limit reached' : 'Under limit',
                      style: TextStyle(
                        fontSize: 11,
                        color: barColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Resets $resetStr',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 16),

                // admin label
                Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined,
                        size: 14, color: Colors.black38),
                    const SizedBox(width: 6),
                    const Text(
                      'ADMIN CONTROLS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _QuotaEditor(
                  currentLimit: limit,
                  recruiterDocId: _r.docId!,
                  recruiterUserId: _r.userId,
                  onSaved: (_) {}, // stream auto-updates _r
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.12)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  // ── action buttons ────────────────────────────────────────────

  Widget _actionButtons(AppLocalizations l10n) {
    return Column(
      children: [
        // verify / unverify
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _toggleStatus,
            icon: Icon(
              _r.isActive
                  ? Icons.cancel_outlined
                  : Icons.verified_rounded,
              size: 18,
              color: Colors.white,
            ),
            label: Text(
              _r.isActive
                  ? l10n.unverifyRecruiter
                  : l10n.verifyRecruiter,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _r.isActive ? Colors.red.shade600 : AppColors.darkGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        // make pro — only when active and not already Pro
        if (_r.isActive && _r.profileStatus != 'Pro') ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _makePro,
              icon: const Icon(Icons.workspace_premium_rounded,
                  size: 18, color: Colors.white),
              label: Text(
                l10n.makeRecruiterPro,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _errorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 15, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Live updates disconnected. Showing last known data.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuotaEditor — unchanged logic, refreshed style
// ─────────────────────────────────────────────────────────────────────────────

class _QuotaEditor extends StatefulWidget {
  final int currentLimit;
  final String recruiterDocId;
  final String recruiterUserId;
  final void Function(int) onSaved;

  const _QuotaEditor({
    required this.currentLimit,
    required this.recruiterDocId,
    required this.recruiterUserId,
    required this.onSaved,
  });

  @override
  State<_QuotaEditor> createState() => _QuotaEditorState();
}

class _QuotaEditorState extends State<_QuotaEditor> {
  late int _limit;
  bool _saving = false;
  final _repo = RecruiterRepository();

  @override
  void initState() {
    super.initState();
    _limit = widget.currentLimit;
  }

  // sync when stream pushes a new limit from outside
  @override
  void didUpdateWidget(_QuotaEditor old) {
    super.didUpdateWidget(old);
    if (old.currentLimit != widget.currentLimit) {
      setState(() => _limit = widget.currentLimit);
    }
  }

  void _adjust(int d) =>
      setState(() => _limit = (_limit + d).clamp(1, 500));

  Future<void> _save() async {
    setState(() => _saving = true);
    await _repo.setJobPostLimitForCurrentMonth(widget.recruiterDocId, _limit);
    
    // Send localized notification to recruiter
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      NotificationService.sendToUser(
        targetUserId: widget.recruiterUserId,
        type: 'quota_updated',
        title: l10n.notif_quota_updated_title,
        description: l10n.notif_quota_updated_desc(_limit),
      );
    }

    widget.onSaved(_limit);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Limit updated to $_limit posts / month'),
          backgroundColor: AppColors.darkGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // stepper row
        Row(
          children: [
            _chip('−10', () => _adjust(-10)),
            const SizedBox(width: 6),
            _chip('−5', () => _adjust(-5)),
            const SizedBox(width: 6),
            _chip('−1', () => _adjust(-1)),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.darkGreen.withOpacity(.2)),
                ),
                child: Text(
                  '$_limit',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _chip('+1', () => _adjust(1)),
            const SizedBox(width: 6),
            _chip('+5', () => _adjust(5)),
            const SizedBox(width: 6),
            _chip('+10', () => _adjust(10)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _limit = 30),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black54,
                side: const BorderSide(color: Colors.black12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reset to 30',
                  style: TextStyle(fontSize: 12)),
            ),
            const Spacer(),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenCeladon,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save limit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _limit == 30
              ? 'Resets to 30 automatically next month.'
              : 'Custom limit of $_limit active this month — resets to 30 next month.',
          style: const TextStyle(fontSize: 11, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _chip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}