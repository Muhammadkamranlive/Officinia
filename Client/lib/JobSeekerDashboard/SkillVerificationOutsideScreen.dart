// // import 'dart:ui';

// // import 'package:client/AppColors/AppColors.dart';
// // import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// // import 'package:client/Server/Model/Recruiter.dart';
// // import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
// // import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';

// // import '../Server/Model/NotificationModel.dart';
// // import '../Server/Repo/Notifications/NotificationsRepository.dart';
// // import '../routes/app_routes.dart';

// // class SkillVerificationOutsideScreen extends StatefulWidget {
// //   final Recruiter recruiter;

// //   const SkillVerificationOutsideScreen({super.key, required this.recruiter});

// //   @override
// //   State<SkillVerificationOutsideScreen> createState() =>
// //       _SkillVerificationOutsideScreenState();
// // }

// // class _SkillVerificationOutsideScreenState
// //     extends State<SkillVerificationOutsideScreen> {
// //   final _skillsSelected = <String>[];
// //   final _noteCtrl = TextEditingController();
// //   bool _loading = false;
// //   final SkillVerificationRequestRepository _repo =
// //       SkillVerificationRequestRepository();

// //   final List<String> _allSkills = [
// //     "Order Receiving & Invoice Entry",
// //     "Counter Customer Assistance",
// //     "CHIFA System Proficiency",
// //     "DAMANCOM System Proficiency",
// //     "CAMSSP System Proficiency",
// //     "Inventory Management",
// //     "Physical Inventory Control",
// //     "CNAS Claims Submission & Follow-up",
// //     "CASNOS Claims Submission & Follow-up",
// //     "CAMSSP Claims Submission & Follow-up",
// //     "Medication Ordering & Tracking",
// //     "Parapharmaceutical Ordering & Tracking",
// //     "Magistral Preparations",
// //     "Overall Pharmacy Management",
// //   ];

// //   @override
// //   Widget build(BuildContext context) {
// //     final userId = context.read<AuthProvider>().user!.userId;

// //     return Scaffold(
// //       resizeToAvoidBottomInset: true, // important to avoid overflow
// //       appBar: AppBar(title: const Text("Request Skill Verification", style: TextStyle(
// //             color: AppColors.darkGreen,
// //             fontWeight: FontWeight.w600,
// //           ),)),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: LayoutBuilder(
// //             builder: (context, constraints) {
// //               return SingleChildScrollView(
// //                 child: ConstrainedBox(
// //                   constraints: BoxConstraints(
// //                     minHeight: constraints.maxHeight,
// //                   ),
// //                   child: IntrinsicHeight(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           "Select Skills to Verify",
// //                           style: TextStyle(fontWeight: FontWeight.bold),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Wrap(
// //                           spacing: 8,
// //                           runSpacing: 8,
// //                           children: _allSkills.map((skill) {
// //                             final selected = _skillsSelected.contains(skill);
// //                             return ConstrainedBox(
// //                               constraints: const BoxConstraints(
// //                                 maxWidth: 300,
// //                               ),
// //                               child: FilterChip(
// //                                 label: Text(
// //                                   skill,
// //                                   softWrap: true,
// //                                   overflow: TextOverflow.ellipsis,
// //                                 ),
// //                                 selected: selected,
// //                                 showCheckmark: true,
// //                                 onSelected: (val) {
// //                                   setState(() {
// //                                     if (val) {
// //                                       _skillsSelected.add(skill);
// //                                     } else {
// //                                       _skillsSelected.remove(skill);
// //                                     }
// //                                   });
// //                                 },
// //                                 backgroundColor: Colors.grey.shade200,
// //                                 selectedColor:
// //                                     AppColors.greenCeladon.withOpacity(0.2),
// //                                 labelStyle: TextStyle(
// //                                   fontSize: 13,
// //                                   color: selected
// //                                       ? AppColors.greenCeladon
// //                                       : Colors.black87,
// //                                 ),
// //                               ),
// //                             );
// //                           }).toList(),
// //                         ),
// //                         const SizedBox(height: 16),
// //                         const Text(
// //                           "Write a Note",
// //                           style: TextStyle(fontWeight: FontWeight.bold),
// //                         ),
// //                         const SizedBox(height: 6),
// //                         TextField(
// //                           controller: _noteCtrl,
// //                           maxLines: null, // allow dynamic height
// //                           minLines: 3,
// //                           decoration: InputDecoration(
// //                             hintText: "Add note to recruiter",
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 16),
// //                         Spacer(), // push button to bottom
// //                         SizedBox(
// //                           width: double.infinity,
// //                           child: ElevatedButton(
// //                             onPressed: _skillsSelected.isEmpty ||
// //                                     _noteCtrl.text.isEmpty ||
// //                                     _loading
// //                                 ? null
// //                                 : () async {
// //                                     setState(() => _loading = true);

// //                                     final request = SkillVerificationRequest(
// //                                       jobSeekerId: userId,
// //                                       recruiterId: widget.recruiter.userId,
// //                                       jobId: null,
// //                                       skills: _skillsSelected,
// //                                       note: _noteCtrl.text,
// //                                       createdAt: DateTime.now(),
// //                                     );

// //                                     await _repo.submitRequest(request);
// //                                     // Send notification to job seeker
// //                                     final notificationRepo = NotificationRepository();
// //                                     await notificationRepo.add(NotificationModel(
// //                                       userId: userId,
// //                                       type: 'skill_verification',
// //                                       title: 'Skill Verification Requested',
// //                                       description:
// //                                       'Your skill verification request has been sent to ${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName} recruiter.',
// //                                       targetId:widget.recruiter.userId ,
// //                                       targetType: 'localNotification',
// //                                       route: AppRoutes.notifications,
// //                                       isRead: false,
// //                                       isSent: false,
// //                                       createdAt: DateTime.now(),
// //                                     ));

// //                                     // Send notification to recruiter
// //                                     await notificationRepo.add(NotificationModel(
// //                                       userId: widget.recruiter.userId,
// //                                       type: 'skill_verification',
// //                                       title: 'Skill Verification Request',
// //                                       description:
// //                                       'A job seeker has requested skill verification for skills ${_skillsSelected.join(',')}.',
// //                                       targetId: widget.recruiter.userId,
// //                                       targetType: 'localNotification',
// //                                       route: AppRoutes.notifications,
// //                                       isRead: false,
// //                                       isSent: false,
// //                                       createdAt: DateTime.now(),
// //                                     ));

// //                                     if (!mounted) return;

// //                                     ScaffoldMessenger.of(context).showSnackBar(
// //                                       const SnackBar(
// //                                         content:
// //                                             Text("Request sent successfully"),
// //                                       ),
// //                                     );

// //                                     setState(() {
// //                                       _loading = false;
// //                                       _skillsSelected.clear();
// //                                       _noteCtrl.clear();
// //                                     });
// //                                     Navigator.pop(context);
// //                                   },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: AppColors.greenCeladon,
// //                               padding: const EdgeInsets.symmetric(vertical: 14),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(18),
// //                               ),
// //                             ),
// //                             child: _loading
// //                                 ? const SizedBox(
// //                                     width: 20,
// //                                     height: 20,
// //                                     child: CircularProgressIndicator(
// //                                       color: Colors.white,
// //                                       strokeWidth: 2,
// //                                     ),
// //                                   )
// //                                 : const Text(
// //                                     "Send Verification Request",
// //                                     style:
// //                                         TextStyle(fontWeight: FontWeight.w700),
// //                                   ),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 16),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:client/AppColors/AppColors.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/Server/Model/NotificationModel.dart';
// import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
// import 'package:client/Server/Model/Recruiter.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../Server/Repo/Notifications/NotificationsRepository.dart';
// import '../routes/app_routes.dart';

// class SkillVerificationOutsideScreen extends StatefulWidget {
//   final Recruiter recruiter;

//   const SkillVerificationOutsideScreen({super.key, required this.recruiter});

//   @override
//   State<SkillVerificationOutsideScreen> createState() =>
//       _SkillVerificationOutsideScreenState();
// }

// class _SkillVerificationOutsideScreenState
//     extends State<SkillVerificationOutsideScreen> {
//   final _skillsSelected = <String>[];
//   final _noteCtrl = TextEditingController();
//   bool _loading = false;
//   bool _loadingSkills = true;
//   List<String> _mySkills = [];

//   final SkillVerificationRequestRepository _repo =
//       SkillVerificationRequestRepository();
//   final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();

//   @override
//   void initState() {
//     super.initState();
//     // ── Fix 1: listen to note changes so button reactively enables ──
//     _noteCtrl.addListener(() => setState(() {}));
//     // ── Fix 2: load skills from job seeker profile ───────────────────
//     _loadMySkills();
//   }

//   Future<void> _loadMySkills() async {
//     final userId = context.read<AuthProvider>().user!.userId;
//     final profile = await _jobSeekerRepo.getByUid(userId);
//     if (!mounted) return;
//     setState(() {
//       _mySkills = profile?.skills ?? [];
//       _loadingSkills = false;
//     });
//   }

//   @override
//   void dispose() {
//     _noteCtrl.dispose();
//     super.dispose();
//   }

//   bool get _canSend =>
//       _skillsSelected.isNotEmpty &&
//       _noteCtrl.text.trim().isNotEmpty &&
//       !_loading;

//   @override
//   Widget build(BuildContext context) {
//     final userId = context.read<AuthProvider>().user!.userId;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text(
//           "Request Skill Verification",
//           style: TextStyle(
//             color: AppColors.darkGreen,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: _loadingSkills
//             ? const Center(child: CircularProgressIndicator())
//             : _mySkills.isEmpty
//                 ? _buildNoSkillsState()
//                 : _buildForm(userId),
//       ),
//     );
//   }

//   // ── No skills on profile ────────────────────────────────────────
//   Widget _buildNoSkillsState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.info_outline_rounded,
//                 size: 48, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             const Text(
//               "No Skills on Your Profile",
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Please add skills to your profile first before requesting verification.",
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Main form ───────────────────────────────────────────────────
//   Widget _buildForm(String userId) {
//     return GestureDetector(
//       // ── Fix 1 continued: tap outside keyboard to dismiss ────────
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Recruiter info banner ──────────────────
//                       _RecruiterBanner(recruiter: widget.recruiter),

//                       const SizedBox(height: 20),

//                       // ── Skills from profile ────────────────────
//                       const Text(
//                         "Select Skills to Verify",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         "Only your profile skills are shown",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade500,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _mySkills.map((skill) {
//                           final selected = _skillsSelected.contains(skill);
//                           return FilterChip(
//                             label: Text(
//                               skill,
//                               softWrap: true,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             selected: selected,
//                             showCheckmark: true,
//                             onSelected: (val) {
//                               setState(() {
//                                 if (val) {
//                                   _skillsSelected.add(skill);
//                                 } else {
//                                   _skillsSelected.remove(skill);
//                                 }
//                               });
//                             },
//                             backgroundColor: Colors.grey.shade200,
//                             selectedColor:
//                                 AppColors.greenCeladon.withOpacity(0.2),
//                             labelStyle: TextStyle(
//                               fontSize: 13,
//                               color: selected
//                                   ? AppColors.greenCeladon
//                                   : Colors.black87,
//                             ),
//                           );
//                         }).toList(),
//                       ),

//                       const SizedBox(height: 20),

//                       // ── Note ───────────────────────────────────
//                       const Text(
//                         "Write a Note",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       TextField(
//                         controller: _noteCtrl,
//                         maxLines: null,
//                         minLines: 3,
//                         textInputAction: TextInputAction.done,
//                         onEditingComplete: () =>
//                             FocusScope.of(context).unfocus(),
//                         decoration: InputDecoration(
//                           hintText:
//                               "e.g. I worked at your pharmacy from 2022–2024",
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: AppColors.greenCeladon,
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const Spacer(),
//                       const SizedBox(height: 20),

//                       // ── Send button ────────────────────────────
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _canSend
//                               ? () async {
//                                   // dismiss keyboard before sending
//                                   FocusScope.of(context).unfocus();
//                                   setState(() => _loading = true);

//                                   final request = SkillVerificationRequest(
//                                     jobSeekerId: userId,
//                                     recruiterId: widget.recruiter.userId,
//                                     jobId: null,
//                                     skills: _skillsSelected,
//                                     note: _noteCtrl.text.trim(),
//                                     createdAt: DateTime.now(),
//                                   );

//                                   await _repo.submitRequest(request);

//                                   final notificationRepo =
//                                       NotificationRepository();

//                                   await notificationRepo.add(NotificationModel(
//                                     userId: userId,
//                                     type: 'skill_verification',
//                                     title: 'Skill Verification Requested',
//                                     description:
//                                         'Your skill verification request has been sent to ${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}.',
//                                     targetId: widget.recruiter.userId,
//                                     targetType: 'localNotification',
//                                     route: AppRoutes.notifications,
//                                     isRead: false,
//                                     isSent: false,
//                                     createdAt: DateTime.now(),
//                                   ));

//                                   await notificationRepo.add(NotificationModel(
//                                     userId: widget.recruiter.userId,
//                                     type: 'skill_verification',
//                                     title: 'Skill Verification Request',
//                                     description:
//                                         'A job seeker has requested skill verification for: ${_skillsSelected.join(', ')}.',
//                                     targetId: widget.recruiter.userId,
//                                     targetType: 'localNotification',
//                                     route: AppRoutes.notifications,
//                                     isRead: false,
//                                     isSent: false,
//                                     createdAt: DateTime.now(),
//                                   ));

//                                   if (!mounted) return;

//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content:
//                                           Text("Request sent successfully"),
//                                       backgroundColor: AppColors.greenCeladon,
//                                       behavior: SnackBarBehavior.floating,
//                                     ),
//                                   );

//                                   setState(() {
//                                     _loading = false;
//                                     _skillsSelected.clear();
//                                     _noteCtrl.clear();
//                                   });

//                                   Navigator.pop(context);
//                                 }
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.greenCeladon,
//                             disabledBackgroundColor:
//                                 Colors.grey.shade300,
//                             padding:
//                                 const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(18),
//                             ),
//                           ),
//                           child: _loading
//                               ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : const Text(
//                                   "Send Verification Request",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ── Recruiter banner shown at the top ──────────────────────────────
// class _RecruiterBanner extends StatelessWidget {
//   final Recruiter recruiter;
//   const _RecruiterBanner({required this.recruiter});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.greenCeladon.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: AppColors.greenCeladon.withOpacity(0.25),
//         ),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: AppColors.greenCeladon.withOpacity(0.15),
//             child: const Icon(
//               Icons.how_to_reg_rounded,
//               color: AppColors.greenCeladon,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   recruiter.pharmacyName ?? 'Pharmacy',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:client/AppColors/AppColors.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/Server/Model/NotificationModel.dart';
// import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
// import 'package:client/Server/Model/Recruiter.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../Server/Repo/Notifications/NotificationsRepository.dart';
// import '../routes/app_routes.dart';

// class SkillVerificationOutsideScreen extends StatefulWidget {
//   final Recruiter recruiter;

//   const SkillVerificationOutsideScreen({super.key, required this.recruiter});

//   @override
//   State<SkillVerificationOutsideScreen> createState() =>
//       _SkillVerificationOutsideScreenState();
// }

// class _SkillVerificationOutsideScreenState
//     extends State<SkillVerificationOutsideScreen> {
//   final _skillsSelected = <String>[];
//   final _noteCtrl = TextEditingController();
//   bool _loading = false;
//   bool _loadingSkills = true;
//   List<String> _mySkills = [];

//   static const String _defaultNote = "Please verify my skills";

//   final SkillVerificationRequestRepository _repo =
//       SkillVerificationRequestRepository();
//   final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();

//   @override
//   void initState() {
//     super.initState();
//     _noteCtrl.addListener(() => setState(() {}));
//     _loadMySkills();
//   }

//   Future<void> _loadMySkills() async {
//     final userId = context.read<AuthProvider>().user!.userId;
//     final profile = await _jobSeekerRepo.getByUid(userId);
//     if (!mounted) return;
//     setState(() {
//       _mySkills = profile?.skills ?? [];
//       _loadingSkills = false;
//     });
//   }

//   @override
//   void dispose() {
//     _noteCtrl.dispose();
//     super.dispose();
//   }

//   /// Returns the effective list of skills to send:
//   /// - If user selected some → use those
//   /// - Otherwise → use ALL profile skills
//   List<String> get _effectiveSkills =>
//       _skillsSelected.isNotEmpty ? List<String>.from(_skillsSelected) : List<String>.from(_mySkills);

//   /// Returns the effective note to send:
//   /// - If user typed something → use that
//   /// - Otherwise → use default message
//   String get _effectiveNote =>
//       _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : _defaultNote;

//   /// Button is always enabled as long as there are skills available and not currently loading
//   bool get _canSend => _mySkills.isNotEmpty && !_loading;

//   @override
//   Widget build(BuildContext context) {
//     final userId = context.read<AuthProvider>().user!.userId;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text(
//           "Request Skill Verification",
//           style: TextStyle(
//             color: AppColors.darkGreen,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: _loadingSkills
//             ? const Center(child: CircularProgressIndicator())
//             : _mySkills.isEmpty
//                 ? _buildNoSkillsState()
//                 : _buildForm(userId),
//       ),
//     );
//   }

//   // ── No skills on profile ────────────────────────────────────────
//   Widget _buildNoSkillsState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.info_outline_rounded,
//                 size: 48, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             const Text(
//               "No Skills on Your Profile",
//               style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Please add skills to your profile first before requesting verification.",
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Main form ───────────────────────────────────────────────────
//   Widget _buildForm(String userId) {
//     final bool isAutoMode =
//         _skillsSelected.isEmpty && _noteCtrl.text.trim().isEmpty;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Recruiter info banner ──────────────────
//                       _RecruiterBanner(recruiter: widget.recruiter),

//                       const SizedBox(height: 20),

//                       // ── Auto-mode hint banner ──────────────────
//                       if (isAutoMode) _buildAutoModeBanner(),

//                       if (isAutoMode) const SizedBox(height: 16),

//                       // ── Skills from profile ────────────────────
//                       Row(
//                         children: [
//                           const Text(
//                             "Select Skills to Verify",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           if (_skillsSelected.isNotEmpty)
//                             GestureDetector(
//                               onTap: () =>
//                                   setState(() => _skillsSelected.clear()),
//                               child: Text(
//                                 "Clear",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.redAccent.shade200,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         isAutoMode
//                             ? "All your skills will be sent automatically"
//                             : "Only your profile skills are shown",
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: isAutoMode
//                               ? AppColors.greenCeladon
//                               : Colors.grey.shade500,
//                         ),
//                       ),
//                       const SizedBox(height: 10),

//                       Wrap(
//                         spacing: 8,
//                         runSpacing: 8,
//                         children: _mySkills.map((skill) {
//                           // In auto-mode, visually highlight all chips
//                           final selected = isAutoMode
//                               ? true
//                               : _skillsSelected.contains(skill);
//                           final isManuallySelected =
//                               _skillsSelected.contains(skill);

//                           return FilterChip(
//                             label: Text(
//                               skill,
//                               softWrap: true,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             selected: selected,
//                             showCheckmark: true,
//                             onSelected: (val) {
//                               setState(() {
//                                 if (val) {
//                                   _skillsSelected.add(skill);
//                                 } else {
//                                   _skillsSelected.remove(skill);
//                                 }
//                               });
//                             },
//                             backgroundColor: Colors.grey.shade200,
//                             selectedColor: isAutoMode
//                                 ? AppColors.greenCeladon.withOpacity(0.12)
//                                 : AppColors.greenCeladon.withOpacity(0.2),
//                             checkmarkColor: isAutoMode
//                                 ? AppColors.greenCeladon.withOpacity(0.6)
//                                 : AppColors.greenCeladon,
//                             labelStyle: TextStyle(
//                               fontSize: 13,
//                               color: selected
//                                   ? AppColors.greenCeladon
//                                   : Colors.black87,
//                               fontStyle: isAutoMode && !isManuallySelected
//                                   ? FontStyle.italic
//                                   : FontStyle.normal,
//                             ),
//                           );
//                         }).toList(),
//                       ),

//                       const SizedBox(height: 20),

//                       // ── Note ───────────────────────────────────
//                       const Text(
//                         "Write a Note",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       TextField(
//                         controller: _noteCtrl,
//                         maxLines: null,
//                         minLines: 3,
//                         textInputAction: TextInputAction.done,
//                         onEditingComplete: () =>
//                             FocusScope.of(context).unfocus(),
//                         decoration: InputDecoration(
//                           hintText: isAutoMode
//                               ? _defaultNote
//                               : "e.g. I worked at your pharmacy from 2022–2024",
//                           hintStyle: TextStyle(
//                             color: isAutoMode
//                                 ? AppColors.greenCeladon.withOpacity(0.6)
//                                 : Colors.grey.shade400,
//                             fontStyle: FontStyle.italic,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: AppColors.greenCeladon,
//                               width: 1.5,
//                             ),
//                           ),
//                           suffixIcon: _noteCtrl.text.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(Icons.clear, size: 18),
//                                   onPressed: () {
//                                     _noteCtrl.clear();
//                                     setState(() {});
//                                   },
//                                 )
//                               : null,
//                         ),
//                       ),

//                       const Spacer(),
//                       const SizedBox(height: 20),

//                       // ── Preview of what will be sent ───────────
//                       if (isAutoMode) _buildSendPreview(),
//                       if (isAutoMode) const SizedBox(height: 12),

//                       // ── Send button ────────────────────────────
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _canSend
//                               ? () async {
//                                   FocusScope.of(context).unfocus();
//                                   setState(() => _loading = true);

//                                   final skillsToSend = _effectiveSkills;
//                                   final noteToSend = _effectiveNote;

//                                   final request = SkillVerificationRequest(
//                                     jobSeekerId: userId,
//                                     recruiterId: widget.recruiter.userId,
//                                     jobId: null,
//                                     skills: skillsToSend,
//                                     note: noteToSend,
//                                     createdAt: DateTime.now(),
//                                   );

//                                   await _repo.submitRequest(request);

//                                   final notificationRepo =
//                                       NotificationRepository();

//                                   await notificationRepo.add(NotificationModel(
//                                     userId: userId,
//                                     type: 'skill_verification',
//                                     title: 'Skill Verification Requested',
//                                     description:
//                                         'Your skill verification request has been sent to ${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}.',
//                                     targetId: widget.recruiter.userId,
//                                     targetType: 'localNotification',
//                                     route: AppRoutes.notifications,
//                                     isRead: false,
//                                     isSent: false,
//                                     createdAt: DateTime.now(),
//                                   ));

//                                   await notificationRepo.add(NotificationModel(
//                                     userId: widget.recruiter.userId,
//                                     type: 'skill_verification',
//                                     title: 'Skill Verification Request',
//                                     description:
//                                         'A job seeker has requested skill verification for: ${skillsToSend.join(', ')}.',
//                                     targetId: widget.recruiter.userId,
//                                     targetType: 'localNotification',
//                                     route: AppRoutes.notifications,
//                                     isRead: false,
//                                     isSent: false,
//                                     createdAt: DateTime.now(),
//                                   ));

//                                   if (!mounted) return;

//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content:
//                                           Text("Request sent successfully"),
//                                       backgroundColor: AppColors.greenCeladon,
//                                       behavior: SnackBarBehavior.floating,
//                                     ),
//                                   );

//                                   setState(() {
//                                     _loading = false;
//                                     _skillsSelected.clear();
//                                     _noteCtrl.clear();
//                                   });

//                                   Navigator.pop(context);
//                                 }
//                               : null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.greenCeladon,
//                             disabledBackgroundColor: Colors.grey.shade300,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(18),
//                             ),
//                           ),
//                           child: _loading
//                               ? const SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : Text(
//                                   isAutoMode
//                                       ? "Send All Skills for Verification"
//                                       : "Send Verification Request",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ── Auto-mode info banner ───────────────────────────────────────
//   Widget _buildAutoModeBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.greenCeladon.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: AppColors.greenCeladon.withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.auto_awesome_rounded,
//             size: 16,
//             color: AppColors.greenCeladon,
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               "No selection needed — tap Send to submit all your skills with a default message.",
//               style: TextStyle(
//                 fontSize: 12,
//                 color: AppColors.greenCeladon,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Preview what will be sent in auto-mode ──────────────────────
//   Widget _buildSendPreview() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Will be sent:",
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey.shade500,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "• ${_mySkills.length} skill${_mySkills.length == 1 ? '' : 's'}: ${_mySkills.join(', ')}",
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             '• Note: "$_defaultNote"',
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey.shade700,
//               fontStyle: FontStyle.italic,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Recruiter banner shown at the top ──────────────────────────────
// class _RecruiterBanner extends StatelessWidget {
//   final Recruiter recruiter;
//   const _RecruiterBanner({required this.recruiter});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.greenCeladon.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: AppColors.greenCeladon.withOpacity(0.25),
//         ),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 22,
//             backgroundColor: AppColors.greenCeladon.withOpacity(0.15),
//             child: const Icon(
//               Icons.how_to_reg_rounded,
//               color: AppColors.greenCeladon,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   recruiter.pharmacyName,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Server/Repo/Notifications/NotificationsRepository.dart';
import '../routes/app_routes.dart';

enum _SelectionMode { allSkills, custom }

class SkillVerificationOutsideScreen extends StatefulWidget {
  final Recruiter recruiter;

  const SkillVerificationOutsideScreen({super.key, required this.recruiter});

  @override
  State<SkillVerificationOutsideScreen> createState() =>
      _SkillVerificationOutsideScreenState();
}

class _SkillVerificationOutsideScreenState
    extends State<SkillVerificationOutsideScreen> {
  _SelectionMode _mode = _SelectionMode.allSkills;
  final _skillsSelected = <String>[];
  final _noteCtrl = TextEditingController();
  bool _loading = false;
  bool _loadingSkills = true;
  List<String> _mySkills = [];

  static const String _defaultNote = "Please verify my skills";

  final SkillVerificationRequestRepository _repo =
      SkillVerificationRequestRepository();
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();

  @override
  void initState() {
    super.initState();
    _noteCtrl.addListener(() => setState(() {}));
    _loadMySkills();
  }

  Future<void> _loadMySkills() async {
    final userId = context.read<AuthProvider>().user!.userId;
    final profile = await _jobSeekerRepo.getByUid(userId);
    if (!mounted) return;
    setState(() {
      _mySkills = profile?.skills ?? [];
      _loadingSkills = false;
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  List<String> get _effectiveSkills =>
      _mode == _SelectionMode.allSkills
          ? List<String>.from(_mySkills)
          : List<String>.from(_skillsSelected);

  String get _effectiveNote =>
      _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : _defaultNote;

  bool get _canSend {
    if (_loading || _mySkills.isEmpty) return false;
    if (_mode == _SelectionMode.custom && _skillsSelected.isEmpty) return false;
    return true;
  }

  void _switchMode(_SelectionMode mode) {
    setState(() {
      _mode = mode;
      if (mode == _SelectionMode.allSkills) _skillsSelected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().user!.userId;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Request Skill Verification",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: _loadingSkills
            ? const Center(child: CircularProgressIndicator())
            : _mySkills.isEmpty
                ? _buildNoSkillsState()
                : _buildForm(userId),
      ),
    );
  }

  Widget _buildNoSkillsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              "No Skills on Your Profile",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Please add skills to your profile first before requesting verification.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(String userId) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecruiterBanner(recruiter: widget.recruiter),
                      const SizedBox(height: 20),

                      // ── Mode toggle ──────────────────────────
                      _buildModeToggle(),
                      const SizedBox(height: 16),

                      // ── Skills section ───────────────────────
                      _buildSkillsSection(),
                      const SizedBox(height: 20),

                      // ── Note ─────────────────────────────────
                      const Text(
                        "Write a Note",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: null,
                        minLines: 3,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          hintText: _defaultNote,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.greenCeladon, width: 1.5),
                          ),
                          suffixIcon: _noteCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _noteCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),

                      // ── Custom mode: no skill selected hint ──
                      if (_mode == _SelectionMode.custom &&
                          _skillsSelected.isEmpty) ...[
                        _buildNoSelectionHint(),
                        const SizedBox(height: 10),
                      ],

                      // ── Send button ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canSend ? () => _submit(userId) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenCeladon,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _mode == _SelectionMode.allSkills
                                      ? "Send All ${_mySkills.length} Skills"
                                      : _skillsSelected.isEmpty
                                          ? "Select Skills to Continue"
                                          : "Send ${_skillsSelected.length} Selected Skill${_skillsSelected.length == 1 ? '' : 's'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Mode toggle pill ──────────────────────────────────────────────
  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(
            label: "All Skills",
            icon: Icons.select_all_rounded,
            selected: _mode == _SelectionMode.allSkills,
            onTap: () => _switchMode(_SelectionMode.allSkills),
          ),
          _ToggleOption(
            label: "Custom Selection",
            icon: Icons.tune_rounded,
            selected: _mode == _SelectionMode.custom,
            onTap: () => _switchMode(_SelectionMode.custom),
          ),
        ],
      ),
    );
  }

  // ── Skills section (adapts to mode) ──────────────────────────────
  Widget _buildSkillsSection() {
    if (_mode == _SelectionMode.allSkills) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 15, color: AppColors.greenCeladon),
              const SizedBox(width: 5),
              Text(
                "All ${_mySkills.length} skills will be sent",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.greenCeladon,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _mySkills
                .map((skill) => _SkillChip(
                      label: skill,
                      selected: true,
                      interactive: false,
                      onTap: null,
                    ))
                .toList(),
          ),
        ],
      );
    }

    // Custom mode
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_skillsSelected.length} of ${_mySkills.length} selected",
              style: TextStyle(
                fontSize: 13,
                color: _skillsSelected.isEmpty
                    ? Colors.grey.shade500
                    : AppColors.greenCeladon,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                if (_skillsSelected.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _skillsSelected.clear()),
                    child: Text(
                      "Clear",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.redAccent.shade200,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                if (_skillsSelected.isNotEmpty) const SizedBox(width: 12),
                if (_skillsSelected.length < _mySkills.length)
                  GestureDetector(
                    onTap: () => setState(() {
                      _skillsSelected
                        ..clear()
                        ..addAll(_mySkills);
                    }),
                    child: Text(
                      "Select All",
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greenCeladon,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _mySkills.map((skill) {
            final selected = _skillsSelected.contains(skill);
            return _SkillChip(
              label: skill,
              selected: selected,
              interactive: true,
              onTap: () => setState(() {
                if (selected) {
                  _skillsSelected.remove(skill);
                } else {
                  _skillsSelected.add(skill);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoSelectionHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded,
              size: 15, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          Text(
            "Tap skills above to select them",
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(String userId) async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final skillsToSend = _effectiveSkills;
    final noteToSend = _effectiveNote;

    final request = SkillVerificationRequest(
      jobSeekerId: userId,
      recruiterId: widget.recruiter.userId,
      jobId: null,
      skills: skillsToSend,
      note: noteToSend,
      createdAt: DateTime.now(),
    );

    await _repo.submitRequest(request);

    final notificationRepo = NotificationRepository();

    await notificationRepo.add(NotificationModel(
      userId: userId,
      type: 'skill_verification',
      title: 'Skill Verification Requested',
      description:
          'Your skill verification request has been sent to ${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}.',
      targetId: widget.recruiter.userId,
      targetType: 'localNotification',
      route: AppRoutes.notifications,
      isRead: false,
      isSent: false,
      createdAt: DateTime.now(),
    ));

    await notificationRepo.add(NotificationModel(
      userId: widget.recruiter.userId,
      type: 'skill_verification',
      title: 'Skill Verification Request',
      description:
          'A job seeker has requested skill verification for: ${skillsToSend.join(', ')}.',
      targetId: widget.recruiter.userId,
      targetType: 'localNotification',
      route: AppRoutes.notifications,
      isRead: false,
      isSent: false,
      createdAt: DateTime.now(),
    ));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request sent successfully"),
        backgroundColor: AppColors.greenCeladon,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _loading = false;
      _skillsSelected.clear();
      _noteCtrl.clear();
      _mode = _SelectionMode.allSkills;
    });

    Navigator.pop(context);
  }
}

// ── Reusable animated skill chip ──────────────────────────────────
class _SkillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool interactive;
  final VoidCallback? onTap;

  const _SkillChip({
    required this.label,
    required this.selected,
    required this.interactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: interactive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.greenCeladon.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.greenCeladon.withOpacity(0.5)
                : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded,
                  size: 13, color: AppColors.greenCeladon),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected ? AppColors.greenCeladon : Colors.black87,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle pill option ────────────────────────────────────────────
class _ToggleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenCeladon : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected ? Colors.white : Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recruiter banner ──────────────────────────────────────────────
class _RecruiterBanner extends StatelessWidget {
  final Recruiter recruiter;
  const _RecruiterBanner({required this.recruiter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenCeladon.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greenCeladon.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.greenCeladon.withOpacity(0.15),
            child: const Icon(Icons.how_to_reg_rounded,
                color: AppColors.greenCeladon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  recruiter.pharmacyName ?? 'Pharmacy',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}