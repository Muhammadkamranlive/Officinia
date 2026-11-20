// import 'dart:ui';
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }


// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   // ───────────── Animations ─────────────
//   late AnimationController _logoController;
//   late AnimationController _glowController;
//   late AnimationController _textController;

//   late Animation<double> _logoScale;
//   late Animation<double> _logoFade;
//   late Animation<double> _glowPulse;

//   late Animation<Offset> _titleSlide;
//   late Animation<double> _titleFade;
//   late Animation<double> _taglineFade;

//   // ───────────── Navigation control ─────────────
//   bool _splashFinished = false;
//   bool _navigated = false;

//   @override
//   void initState() {
//     super.initState();

//     _initAnimations();
//     _startSplashTimer();
//   }

//   // ───────────── Init animations ─────────────
//   void _initAnimations() {
//     _logoController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );

//     _logoScale = CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeOutExpo,
//     );

//     _logoFade = CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeIn,
//     );

//     _glowController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _glowPulse = Tween<double>(begin: .2, end: .6).animate(
//       CurvedAnimation(
//         parent: _glowController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _textController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _titleSlide = Tween(
//       begin: const Offset(0, .35),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _textController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _titleFade = CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeIn,
//     );

//     _taglineFade = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _textController,
//         curve: const Interval(.4, 1, curve: Curves.easeIn),
//       ),
//     );

//     _logoController.forward();

//     Future.delayed(const Duration(milliseconds: 700), () {
//       _glowController.repeat(reverse: true);
//     });

//     Future.delayed(const Duration(milliseconds: 1200), () {
//       _textController.forward();
//     });
//   }

//   // ───────────── Splash timer ─────────────
//   void _startSplashTimer() {
//     Future.delayed(const Duration(seconds: 3), () {
//       _splashFinished = true;
//       _tryNavigate();
//     });
//   }

//   // ───────────── Auth + Splash sync ─────────────
//   void _tryNavigate() {
//     if (!mounted || _navigated) return;

//     final auth = context.read<AuthProvider>();

//     if (auth.isLoading || !_splashFinished) return;

//     _navigated = true;

//     final user = auth.user;

//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final adminRepo = AdminRepository();
//         final profile = await adminRepo.getByUid(user.userId);
//         if (profile == null) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//               const AdminAccountScreen(mode: AdminFormMode.create),
//             ),
//           );
//         } else {
//           if (!mounted) return;
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (profile == null) {
//             if (!mounted) return;
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                 const RecruiterAccountScreen(mode: AccountFormMode.create),
//               ),
//             );
//           } else {
//             if (!mounted) return;
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (profile == null) {
//             if (!mounted) return;
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const JobSeekerAccountScreen(
//                   mode: JobSeekerFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             if (!mounted) return;
//             Navigator.pushReplacementNamed(context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   late AuthProvider _authProvider;

//   @override
//   void didChangeDependencies()
//   {
//     super.didChangeDependencies();
//     // store reference once
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   @override
//   void dispose() {
//     // safely remove listener using stored reference
//     _authProvider.removeListener(_tryNavigate);
//     _logoController.dispose();
//     _glowController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   // ───────────── UI ─────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.greenCeladon,
//               Color(0xFF5F9E87),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               FadeTransition(
//                 opacity: _logoFade,
//                 child: ScaleTransition(
//                   scale: _logoScale,
//                   child: AnimatedBuilder(
//                     animation: _glowPulse,
//                     builder: (_, __) {
//                       return Container(
//                         height: 100,
//                         width: 100,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: const LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               AppColors.beigeWhite,
//                               AppColors.pinkO,
//                             ],
//                           ),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppColors.pinkO
//                                   .withOpacity(_glowPulse.value),
//                               blurRadius: 40,
//                               spreadRadius: 3,
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           "O",
//                           style: TextStyle(
//                             fontSize: 90,
//                             fontWeight: FontWeight.w700,
//                             height: 1,
//                             color: AppColors.greenCeladon,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               FadeTransition(
//                 opacity: _titleFade,
//                 child: SlideTransition(
//                   position: _titleSlide,
//                   child: Column(
//                     children: [
//                       Text(
//                         "Ophicina",
//                         style: TextStyle(
//                           fontSize: 45,
//                           letterSpacing: 2.6,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       FadeTransition(
//                         opacity: _taglineFade,
//                         child: Text(
//                           "Your opportunity is here",
//                           style: TextStyle(
//                             fontSize: 16,
//                             letterSpacing: 1.3,
//                             color: AppColors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:ui';
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';
// import 'dart:math' as math;

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {

//   // ── Logo: spin-in + overshoot bounce ────────────────────────
//   late AnimationController _logoCtrl;
//   late Animation<double>   _logoScale;
//   late Animation<double>   _logoRotate;
//   late Animation<double>   _logoFade;

//   // ── Spinning arc ring (disappears after one full rotation) ───
//   late AnimationController _ringCtrl;
//   late Animation<double>   _ringRotate;
//   late Animation<double>   _ringFade;

//   // ── Pink "O" letter pop ──────────────────────────────────────
//   late AnimationController _letterCtrl;
//   late Animation<double>   _letterScale;

//   // ── 4-dot burst ─────────────────────────────────────────────
//   late AnimationController _dotsCtrl;
//   late Animation<double>   _dotsScale;
//   late Animation<double>   _dotsFade;

//   // ── Glow pulse (infinite) ────────────────────────────────────
//   late AnimationController _glowCtrl;
//   late Animation<double>   _glowPulse;

//   // ── Title slide-up ───────────────────────────────────────────
//   late AnimationController _titleCtrl;
//   late Animation<Offset>   _titleSlide;
//   late Animation<double>   _titleFade;

//   // ── Tagline fade ─────────────────────────────────────────────
//   late AnimationController _taglineCtrl;
//   late Animation<double>   _taglineFade;

//   // ── Navigation ───────────────────────────────────────────────
//   bool _splashFinished = false;
//   bool _navigated      = false;
//   late AuthProvider _authProvider;

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _startSplashTimer();
//   }

//   void _initAnimations() {
//     // ── 1. Logo circle: scale 0 → spin → overshoot bounce ──────
//     _logoCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     );

//     // Scale: 0 → 1.12 → 0.95 → 1.0  (spring feel)
//     _logoScale = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: 0.0, end: 1.12)
//             .chain(CurveTween(curve: Curves.easeOutExpo)),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 1.12, end: 0.95)
//             .chain(CurveTween(curve: Curves.easeInOut)),
//         weight: 20,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 0.95, end: 1.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 20,
//       ),
//     ]).animate(_logoCtrl);

//     // Rotation: -180° → 8° → 0°
//     _logoRotate = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: -math.pi, end: 0.14)
//             .chain(CurveTween(curve: Curves.easeOutExpo)),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 0.14, end: -0.05)
//             .chain(CurveTween(curve: Curves.easeInOut)),
//         weight: 20,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: -0.05, end: 0.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 20,
//       ),
//     ]).animate(_logoCtrl);

//     _logoFade = CurvedAnimation(
//         parent: _logoCtrl, curve: const Interval(0, 0.3, curve: Curves.easeIn));

//     // ── 2. Arc ring: spins once then fades out ──────────────────
//     _ringCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _ringRotate = Tween<double>(begin: 0, end: 2 * math.pi)
//         .animate(CurvedAnimation(
//             parent: _ringCtrl, curve: Curves.easeInOut));

//     _ringFade = TweenSequence<double>([
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 1.0), weight: 70),
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 0.0)
//               .chain(CurveTween(curve: Curves.easeIn)),
//           weight: 30),
//     ]).animate(_ringCtrl);

//     // ── 3. Letter "O" pop: delayed elastic scale ────────────────
//     _letterCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _letterScale = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: 0.0, end: 1.18)
//             .chain(CurveTween(curve: Curves.easeOutBack)),
//         weight: 70,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 1.18, end: 1.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 30,
//       ),
//     ]).animate(_letterCtrl);

//     // ── 4. Dot burst ─────────────────────────────────────────────
//     _dotsCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _dotsScale = Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeOut));

//     _dotsFade = TweenSequence<double>([
//       TweenSequenceItem(
//           tween: Tween(begin: 0.0, end: 1.0)
//               .chain(CurveTween(curve: Curves.easeIn)),
//           weight: 30),
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 0.0)
//               .chain(CurveTween(curve: Curves.easeOut)),
//           weight: 70),
//     ]).animate(_dotsCtrl);

//     // ── 5. Glow pulse (infinite) ──────────────────────────────────
//     _glowCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _glowPulse = Tween<double>(begin: 0.2, end: 0.65).animate(
//         CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

//     // ── 6. Title ──────────────────────────────────────────────────
//     _titleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _titleSlide = Tween<Offset>(
//       begin: const Offset(0, 0.35),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));

//     _titleFade = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);

//     // ── 7. Tagline ────────────────────────────────────────────────
//     _taglineCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );

//     _taglineFade = CurvedAnimation(
//         parent: _taglineCtrl, curve: Curves.easeIn);

//     // ── Sequence start times ──────────────────────────────────────
//     _logoCtrl.forward();                                          // t=0ms

//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) _ringCtrl.forward();                           // t=100ms
//     });

//     Future.delayed(const Duration(milliseconds: 700), () {
//       if (mounted) {
//         _letterCtrl.forward();                                    // t=700ms
//         _dotsCtrl.forward();
//         _glowCtrl.repeat(reverse: true);
//       }
//     });

//     Future.delayed(const Duration(milliseconds: 1300), () {
//       if (mounted) _titleCtrl.forward();                          // t=1300ms
//     });

//     Future.delayed(const Duration(milliseconds: 1800), () {
//       if (mounted) _taglineCtrl.forward();                        // t=1800ms
//     });
//   }

//   // ── Splash timer ──────────────────────────────────────────────
//   void _startSplashTimer() {
//     Future.delayed(const Duration(seconds: 3), () {
//       _splashFinished = true;
//       _tryNavigate();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   void _tryNavigate() {
//     if (!mounted || _navigated) return;
//     final auth = context.read<AuthProvider>();
//     if (auth.isLoading || !_splashFinished) return;
//     _navigated = true;
//     final user = auth.user;
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final profile = await AdminRepository().getByUid(user.userId);
//         if (!mounted) return;
//         if (profile == null) {
//           Navigator.pushReplacement(context, MaterialPageRoute(
//             builder: (_) =>
//                 const AdminAccountScreen(mode: AdminFormMode.create)));
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(context, MaterialPageRoute(
//               builder: (_) => BlockedScreen(user: user)));
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(context, MaterialPageRoute(
//               builder: (_) => const RecruiterAccountScreen(
//                   mode: AccountFormMode.create)));
//           } else {
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(context, MaterialPageRoute(
//               builder: (_) => BlockedScreen(user: user)));
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(context, MaterialPageRoute(
//               builder: (_) => const JobSeekerAccountScreen(
//                   mode: JobSeekerFormMode.create)));
//           } else {
//             Navigator.pushReplacementNamed(
//                 context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   @override
//   void dispose() {
//     _authProvider.removeListener(_tryNavigate);
//     _logoCtrl.dispose();
//     _ringCtrl.dispose();
//     _letterCtrl.dispose();
//     _dotsCtrl.dispose();
//     _glowCtrl.dispose();
//     _titleCtrl.dispose();
//     _taglineCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColors.greenCeladon, Color(0xFF5F9E87)],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildLogo(),
//               const SizedBox(height: 24),
//               _buildTitle(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Logo assembly ─────────────────────────────────────────────
//   Widget _buildLogo() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _logoCtrl, _ringCtrl, _letterCtrl, _dotsCtrl, _glowCtrl,
//       ]),
//       builder: (_, __) {
//         return FadeTransition(
//           opacity: _logoFade,
//           child: Transform.scale(
//             scale: _logoScale.value,
//             child: Transform.rotate(
//               angle: _logoRotate.value,
//               child: SizedBox(
//                 width: 120,
//                 height: 120,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // ── Glow backdrop ──────────────────────────
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.pinkO
//                                 .withOpacity(_glowPulse.value),
//                             blurRadius: 48,
//                             spreadRadius: 6,
//                           ),
//                         ],
//                       ),
//                     ),

//                     // ── Circle background ──────────────────────
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [AppColors.beigeWhite, AppColors.pinkO],
//                         ),
//                       ),
//                     ),

//                     // ── Spinning arc ring ──────────────────────
//                     Opacity(
//                       opacity: _ringFade.value,
//                       child: Transform.rotate(
//                         angle: _ringRotate.value,
//                         child: CustomPaint(
//                           size: const Size(112, 112),
//                           painter: _ArcRingPainter(
//                             color: AppColors.pinkO,
//                           ),
//                         ),
//                       ),
//                     ),

//                     // ── 4 burst dots ───────────────────────────
//                     ..._buildDots(),

//                     // ── The "O" letter ─────────────────────────
//                     Transform.scale(
//                       scale: _letterScale.value,
//                       child: Text(
//                         'O',
//                         style: TextStyle(
//                           fontSize: 86,
//                           fontWeight: FontWeight.w700,
//                           height: 1,
//                           color: AppColors.greenCeladon,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ── 4 dots at N/E/S/W that burst outward then fade ───────────
//   List<Widget> _buildDots() {
//     const radius = 62.0;
//     const dotSize = 7.0;
//     final angles = [
//       -math.pi / 2, // top
//       0.0,          // right
//       math.pi / 2,  // bottom
//       math.pi,      // left
//     ];

//     return angles.map((angle) {
//       final dx = math.cos(angle) * radius * _dotsScale.value;
//       final dy = math.sin(angle) * radius * _dotsScale.value;

//       return Transform.translate(
//         offset: Offset(dx, dy),
//         child: Opacity(
//           opacity: _dotsFade.value,
//           child: Container(
//             width: dotSize,
//             height: dotSize,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: AppColors.pinkO,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   // ── Title + tagline ───────────────────────────────────────────
//   Widget _buildTitle() {
//     return Column(
//       children: [
//         FadeTransition(
//           opacity: _titleFade,
//           child: SlideTransition(
//             position: _titleSlide,
//             child: Text(
//               'Ophicina',
//               style: TextStyle(
//                 fontSize: 45,
//                 letterSpacing: 2.6,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         FadeTransition(
//           opacity: _taglineFade,
//           child: Text(
//             'Your opportunity is here',
//             style: TextStyle(
//               fontSize: 16,
//               letterSpacing: 1.3,
//               color: AppColors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  ARC RING PAINTER  — draws a partial arc that spins once
// // ─────────────────────────────────────────────────────────────────
// class _ArcRingPainter extends CustomPainter {
//   final Color color;
//   const _ArcRingPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width:  size.width,
//       height: size.height,
//     );

//     // Leading arc (bright)
//     final paintLead = Paint()
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 2.5
//       ..strokeCap   = StrokeCap.round
//       ..color       = color.withOpacity(0.9);

//     // Trailing arc (faded)
//     final paintTrail = Paint()
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 2.5
//       ..strokeCap   = StrokeCap.round
//       ..shader      = SweepGradient(
//         colors: [Colors.transparent, color.withOpacity(0.4)],
//         startAngle: 0,
//         endAngle: math.pi * 1.5,
//       ).createShader(rect);

//     canvas.drawArc(rect, 0, math.pi * 1.5, false, paintTrail);
//     canvas.drawArc(rect, math.pi * 1.5, 0.5, false, paintLead);
//   }

//   @override
//   bool shouldRepaint(_ArcRingPainter old) => old.color != color;
// }

// import 'dart:ui';
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';
// import 'dart:math' as math;

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {

//   // ── Logo: spin-in + overshoot bounce ────────────────────────
//   late AnimationController _logoCtrl;
//   late Animation<double>   _logoScale;
//   late Animation<double>   _logoRotate;
//   late Animation<double>   _logoFade;

//   // ── Spinning arc ring ────────────────────────────────────────
//   late AnimationController _ringCtrl;
//   late Animation<double>   _ringRotate;
//   late Animation<double>   _ringFade;

//   // ── Pink "O" letter pop ──────────────────────────────────────
//   late AnimationController _letterCtrl;
//   late Animation<double>   _letterScale;

//   // ── 4-dot burst ─────────────────────────────────────────────
//   late AnimationController _dotsCtrl;
//   late Animation<double>   _dotsScale;
//   late Animation<double>   _dotsFade;

//   // ── Glow pulse (infinite) ────────────────────────────────────
//   late AnimationController _glowCtrl;
//   late Animation<double>   _glowPulse;

//   // ── Title slide-up ───────────────────────────────────────────
//   late AnimationController _titleCtrl;
//   late Animation<Offset>   _titleSlide;
//   late Animation<double>   _titleFade;

//   // ── Tagline fade ─────────────────────────────────────────────
//   late AnimationController _taglineCtrl;
//   late Animation<double>   _taglineFade;

//   // ── Navigation ───────────────────────────────────────────────
//   bool _splashFinished = false;
//   bool _navigated      = false;
//   late AuthProvider _authProvider;

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _startSplashTimer();
//   }

//   void _initAnimations() {
//     // ── 1. Logo circle spin-in  (was 1100ms → now 1800ms) ───────
//     _logoCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     );

//     _logoScale = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: 0.0, end: 1.12)
//             .chain(CurveTween(curve: Curves.easeOutExpo)),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 1.12, end: 0.95)
//             .chain(CurveTween(curve: Curves.easeInOut)),
//         weight: 20,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 0.95, end: 1.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 20,
//       ),
//     ]).animate(_logoCtrl);

//     _logoRotate = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: -math.pi, end: 0.14)
//             .chain(CurveTween(curve: Curves.easeOutExpo)),
//         weight: 60,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 0.14, end: -0.05)
//             .chain(CurveTween(curve: Curves.easeInOut)),
//         weight: 20,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: -0.05, end: 0.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 20,
//       ),
//     ]).animate(_logoCtrl);

//     _logoFade = CurvedAnimation(
//       parent: _logoCtrl,
//       curve: const Interval(0, 0.3, curve: Curves.easeIn),
//     );

//     // ── 2. Arc ring  (was 900ms → now 1500ms) ───────────────────
//     _ringCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _ringRotate = Tween<double>(begin: 0, end: 2 * math.pi).animate(
//       CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut),
//     );

//     _ringFade = TweenSequence<double>([
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 1.0), weight: 70),
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 0.0)
//               .chain(CurveTween(curve: Curves.easeIn)),
//           weight: 30),
//     ]).animate(_ringCtrl);

//     // ── 3. Letter pop  (was 500ms → now 900ms) ──────────────────
//     _letterCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _letterScale = TweenSequence<double>([
//       TweenSequenceItem(
//         tween: Tween(begin: 0.0, end: 1.22)
//             .chain(CurveTween(curve: Curves.easeOutBack)),
//         weight: 70,
//       ),
//       TweenSequenceItem(
//         tween: Tween(begin: 1.22, end: 1.0)
//             .chain(CurveTween(curve: Curves.easeOut)),
//         weight: 30,
//       ),
//     ]).animate(_letterCtrl);

//     // ── 4. Dot burst  (was 500ms → now 900ms) ───────────────────
//     _dotsCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _dotsScale = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeOut),
//     );

//     _dotsFade = TweenSequence<double>([
//       TweenSequenceItem(
//           tween: Tween(begin: 0.0, end: 1.0)
//               .chain(CurveTween(curve: Curves.easeIn)),
//           weight: 25),
//       TweenSequenceItem(
//           tween: Tween(begin: 1.0, end: 0.0)
//               .chain(CurveTween(curve: Curves.easeOut)),
//           weight: 75),
//     ]).animate(_dotsCtrl);

//     // ── 5. Glow pulse  (was 1800ms → now 2400ms per cycle) ──────
//     _glowCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2400),
//     );

//     _glowPulse = Tween<double>(begin: 0.2, end: 0.7).animate(
//       CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
//     );

//     // ── 6. Title slide-up  (was 700ms → now 1100ms) ─────────────
//     _titleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1100),
//     );

//     _titleSlide = Tween<Offset>(
//       begin: const Offset(0, 0.4),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));

//     _titleFade = CurvedAnimation(
//       parent: _titleCtrl,
//       curve: Curves.easeIn,
//     );

//     // ── 7. Tagline  (was 600ms → now 1000ms) ────────────────────
//     _taglineCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _taglineFade = CurvedAnimation(
//       parent: _taglineCtrl,
//       curve: Curves.easeIn,
//     );

//     // ── Staggered start times (all delays doubled+) ──────────────
//     //
//     //   Stage                 Old delay    New delay
//     //   Logo spin-in          0 ms         0 ms
//     //   Arc ring start        100 ms       200 ms
//     //   Letter + dots pop     700 ms       1 800 ms   ← wait for logo to land
//     //   Glow pulse start      700 ms       1 800 ms
//     //   Title slide-up        1 300 ms     2 800 ms   ← letter visible ~1s
//     //   Tagline fade-in       1 800 ms     4 200 ms   ← title visible ~1.4s
//     //
//     _logoCtrl.forward();                                        // t = 0 ms

//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted) _ringCtrl.forward();                         // t = 200 ms
//     });

//     Future.delayed(const Duration(milliseconds: 1800), () {
//       if (mounted) {
//         _letterCtrl.forward();                                  // t = 1 800 ms
//         _dotsCtrl.forward();
//         _glowCtrl.repeat(reverse: true);
//       }
//     });

//     Future.delayed(const Duration(milliseconds: 2800), () {
//       if (mounted) _titleCtrl.forward();                        // t = 2 800 ms
//     });

//     Future.delayed(const Duration(milliseconds: 4200), () {
//       if (mounted) _taglineCtrl.forward();                      // t = 4 200 ms
//     });
//   }

//   // ── Splash total hold  (was 3 s → now 6 s) ───────────────────
//   void _startSplashTimer() {
//     Future.delayed(const Duration(seconds: 6), () {
//       _splashFinished = true;
//       _tryNavigate();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   void _tryNavigate() {
//     if (!mounted || _navigated) return;
//     final auth = context.read<AuthProvider>();
//     if (auth.isLoading || !_splashFinished) return;
//     _navigated = true;
//     final user = auth.user;
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final profile = await AdminRepository().getByUid(user.userId);
//         if (!mounted) return;
//         if (profile == null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const AdminAccountScreen(mode: AdminFormMode.create),
//             ),
//           );
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (_) => BlockedScreen(user: user)));
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const RecruiterAccountScreen(
//                     mode: AccountFormMode.create),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (_) => BlockedScreen(user: user)));
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const JobSeekerAccountScreen(
//                     mode: JobSeekerFormMode.create),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(
//                 context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   @override
//   void dispose() {
//     _authProvider.removeListener(_tryNavigate);
//     _logoCtrl.dispose();
//     _ringCtrl.dispose();
//     _letterCtrl.dispose();
//     _dotsCtrl.dispose();
//     _glowCtrl.dispose();
//     _titleCtrl.dispose();
//     _taglineCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColors.greenCeladon, Color(0xFF5F9E87)],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildLogo(),
//               const SizedBox(height: 28),
//               _buildTitle(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Logo assembly ─────────────────────────────────────────────
//   Widget _buildLogo() {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _logoCtrl, _ringCtrl, _letterCtrl, _dotsCtrl, _glowCtrl,
//       ]),
//       builder: (_, __) {
//         return FadeTransition(
//           opacity: _logoFade,
//           child: Transform.scale(
//             scale: _logoScale.value,
//             child: Transform.rotate(
//               angle: _logoRotate.value,
//               child: SizedBox(
//                 width: 120,
//                 height: 120,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // ── Glow backdrop ──────────────────────────
//                     Container(
//                       width: 120,
//                       height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: AppColors.pinkO
//                                 .withOpacity(_glowPulse.value),
//                             blurRadius: 56,
//                             spreadRadius: 8,
//                           ),
//                         ],
//                       ),
//                     ),

//                     // ── Circle background ──────────────────────
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [AppColors.beigeWhite, AppColors.pinkO],
//                         ),
//                       ),
//                     ),

//                     // ── Spinning arc ring ──────────────────────
//                     Opacity(
//                       opacity: _ringFade.value,
//                       child: Transform.rotate(
//                         angle: _ringRotate.value,
//                         child: CustomPaint(
//                           size: const Size(112, 112),
//                           painter: _ArcRingPainter(color: AppColors.pinkO),
//                         ),
//                       ),
//                     ),

//                     // ── 4 burst dots ───────────────────────────
//                     ..._buildDots(),

//                     // ── The "O" letter ─────────────────────────
//                     Transform.scale(
//                       scale: _letterScale.value,
//                       child: Text(
//                         'O',
//                         style: TextStyle(
//                           fontSize: 86,
//                           fontWeight: FontWeight.w700,
//                           height: 1,
//                           color: AppColors.greenCeladon,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<Widget> _buildDots() {
//     const radius  = 62.0;
//     const dotSize = 7.0;
//     final angles  = [
//       -math.pi / 2, // top
//       0.0,          // right
//       math.pi / 2,  // bottom
//       math.pi,      // left
//     ];

//     return angles.map((angle) {
//       final dx = math.cos(angle) * radius * _dotsScale.value;
//       final dy = math.sin(angle) * radius * _dotsScale.value;

//       return Transform.translate(
//         offset: Offset(dx, dy),
//         child: Opacity(
//           opacity: _dotsFade.value,
//           child: Container(
//             width: dotSize,
//             height: dotSize,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: AppColors.pinkO,
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   Widget _buildTitle() {
//     return Column(
//       children: [
//         FadeTransition(
//           opacity: _titleFade,
//           child: SlideTransition(
//             position: _titleSlide,
//             child: Text(
//               'Ophicina',
//               style: TextStyle(
//                 fontSize: 45,
//                 letterSpacing: 2.6,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.white,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         FadeTransition(
//           opacity: _taglineFade,
//           child: Text(
//             'Your opportunity is here',
//             style: TextStyle(
//               fontSize: 16,
//               letterSpacing: 1.3,
//               color: AppColors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  ARC RING PAINTER
// // ─────────────────────────────────────────────────────────────────
// class _ArcRingPainter extends CustomPainter {
//   final Color color;
//   const _ArcRingPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width:  size.width,
//       height: size.height,
//     );

//     final paintTrail = Paint()
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 2.5
//       ..strokeCap   = StrokeCap.round
//       ..shader      = SweepGradient(
//         colors: [Colors.transparent, color.withOpacity(0.4)],
//         startAngle: 0,
//         endAngle:   math.pi * 1.5,
//       ).createShader(rect);

//     final paintLead = Paint()
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 2.5
//       ..strokeCap   = StrokeCap.round
//       ..color       = color.withOpacity(0.9);

//     canvas.drawArc(rect, 0,            math.pi * 1.5, false, paintTrail);
//     canvas.drawArc(rect, math.pi * 1.5, 0.5,          false, paintLead);
//   }

//   @override
//   bool shouldRepaint(_ArcRingPainter old) => old.color != color;
// }


// import 'dart:math' as math;
// import 'package:client/routes/app_routes.dart';
// import 'package:flutter/material.dart';

// // ─────────────────────────────────────────────────────────────────
// //  SPLASH SCREEN  –  Ventures Pastries style
// //
// //  Animation sequence:
// //   Phase 1 (0–800 ms)   : White bg + food icon trellis visible,
// //                           green organic blob holds centre
// //   Phase 2 (800–1600 ms): Blob scales up and morphs to fill screen
// //   Phase 3 (1600–2200 ms): White rounded-corner wipe sweeps from
// //                           bottom-right to top-left (page-turn feel)
// //   Phase 4 (2200–3000 ms): "WELCOME" text fades + slides up
// //   Phase 5 (3000 ms +)  : Navigate to next screen
// // ─────────────────────────────────────────────────────────────────

// class SplashScreen extends StatefulWidget {
//   /// Called when the splash finishes – push your real route here.
//   final VoidCallback? onFinished;

//   const SplashScreen({super.key, this.onFinished});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   // ── Blob expand ──────────────────────────────────────────────
//   late AnimationController _blobCtrl;
//   late Animation<double>   _blobScale;
//   late Animation<double>   _blobMorph; // 0 = organic, 1 = full-circle

//   // ── Corner wipe ──────────────────────────────────────────────
//   late AnimationController _wipeCtrl;
//   late Animation<double>   _wipeProgress;

//   // ── Welcome text ─────────────────────────────────────────────
//   late AnimationController _textCtrl;
//   late Animation<double>   _textFade;
//   late Animation<Offset>   _textSlide;

//   // ── Icon trellis opacity ─────────────────────────────────────
//   late AnimationController _iconsCtrl;
//   late Animation<double>   _iconsFade;

//   static const Color _green      = Color(0xFF1A9E7A);
//   static const Color _greenDark  = Color(0xFF157A60);
//   static const Color _white      = Color(0xFFFFFFFF);
//   static const Color _iconColor  = Color(0xFFB8E8DC);

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _runSequence();
//   }

//   void _setupAnimations() {
//     // ── Blob ────────────────────────────────────────────────────
//     _blobCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _blobScale = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeInOutCubic,
//     );
//     _blobMorph = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeIn,
//     );

//     // ── Corner wipe ─────────────────────────────────────────────
//     _wipeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 650),
//     );
//     _wipeProgress = CurvedAnimation(
//       parent: _wipeCtrl,
//       curve: Curves.easeInOutQuart,
//     );

//     // ── Welcome text ────────────────────────────────────────────
//     _textCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _textFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
//     _textSlide = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end:   Offset.zero,
//     ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

//     // ── Icons ───────────────────────────────────────────────────
//     _iconsCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _iconsFade = Tween<double>(begin: 1.0, end: 0.0)
//         .animate(CurvedAnimation(parent: _iconsCtrl, curve: Curves.easeIn));
//   }

//   Future<void> _runSequence() async {
//     // Phase 1: Hold initial state (blob visible, icons visible)
//     await Future.delayed(const Duration(milliseconds: 700));

//     // Phase 2: Icons fade out + blob expands simultaneously
//     _iconsCtrl.forward();
//     await _blobCtrl.forward();

//     await Future.delayed(const Duration(milliseconds: 100));

//     // Phase 3: White corner wipe
//     await _wipeCtrl.forward();

//     await Future.delayed(const Duration(milliseconds: 150));

//     // Phase 4: Welcome text slides in
//     await _textCtrl.forward();

//     // Phase 5: Hold then navigate
//     await Future.delayed(const Duration(milliseconds: 1200));

//     if (mounted) {
//       widget.onFinished?.call();
//     }
//   }

//   @override
//   void dispose() {
//     _blobCtrl.dispose();
//     _wipeCtrl.dispose();
//     _textCtrl.dispose();
//     _iconsCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: _white,
//       body: AnimatedBuilder(
//         animation: Listenable.merge([
//           _blobCtrl, _wipeCtrl, _textCtrl, _iconsCtrl,
//         ]),
//         builder: (context, _) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               // ── Layer 1: White bg + food icon trellis ────────
//               _buildIconTrellis(size),

//               // ── Layer 2: Expanding green blob ────────────────
//               _buildBlob(size),

//               // ── Layer 3: Logo (always on top of green) ───────
//               _buildLogo(),

//               // ── Layer 4: Corner wipe (white sheet) ───────────
//               if (_wipeCtrl.value > 0)
//                 _buildCornerWipe(size),

//               // ── Layer 5: Welcome text ─────────────────────────
//               if (_textCtrl.value > 0)
//                 _buildWelcomeText(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // ── Food icon trellis ─────────────────────────────────────────
//   Widget _buildIconTrellis(Size size) {
//     return FadeTransition(
//       opacity: _iconsFade,
//       child: CustomPaint(
//         size: size,
//         painter: _IconTrellisPainter(color: _iconColor),
//       ),
//     );
//   }

//   // ── Green organic blob that expands to fill screen ────────────
//   Widget _buildBlob(Size size) {
//     final maxDimension = math.sqrt(
//       size.width * size.width + size.height * size.height,
//     ) * 1.05;

//     // Initial blob diameter (organic, roughly 55% of screen width)
//     const initialD = 0.55;
//     final targetD  = maxDimension / (size.width * initialD);

//     final currentScale = 1.0 + (_blobScale.value * (targetD - 1.0));

//     return Center(
//       child: Transform.scale(
//         scale: currentScale,
//         child: SizedBox(
//           width:  size.width * initialD,
//           height: size.width * initialD,
//           child: CustomPaint(
//             painter: _BlobPainter(
//               color: _green,
//               morphProgress: _blobMorph.value,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Logo (centred, upper-half) ────────────────────────────────
//   Widget _buildLogo() {
//     return Align(
//       alignment: const Alignment(0, -0.25),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Brand name
//           RichText(
//             text: const TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Ophicina',
//                   style: TextStyle(
//                     fontFamily: 'serif',
//                     fontSize:   32,
//                     fontWeight: FontWeight.w800,
//                     color:      _white,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//                 TextSpan(
//                   // Small leaf/star accent
//                   text: '✦',
//                   style: TextStyle(
//                     fontSize:  20,
//                     color:     _white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Your opportunity is here',
//             style: TextStyle(
//               fontSize:      13,
//               fontWeight:    FontWeight.w400,
//               color:         _white,
//               letterSpacing: 4.0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── White corner wipe from bottom-right ──────────────────────
//   Widget _buildCornerWipe(Size size) {
//     return CustomPaint(
//       size: size,
//       painter: _CornerWipePainter(
//         progress: _wipeProgress.value,
//         color: _white,
//       ),
//     );
//   }

//   // ── WELCOME text ──────────────────────────────────────────────
//   Widget _buildWelcomeText() {
//     return Align(
//       alignment: const Alignment(0, 0.20),
//       child: FadeTransition(
//         opacity: _textFade,
//         child: SlideTransition(
//           position: _textSlide,
//           child: const Text(
//             'WELCOME',
//             style: TextStyle(
//               fontSize:      26,
//               fontWeight:    FontWeight.w300,
//               color:         _green,
//               letterSpacing: 8.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  BLOB PAINTER  –  organic rounded shape that morphs to a circle
// // ─────────────────────────────────────────────────────────────────
// class _BlobPainter extends CustomPainter {
//   final Color  color;
//   final double morphProgress; // 0 = organic blob, 1 = full circle

//   const _BlobPainter({required this.color, required this.morphProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width  / 2;
//     final cy = size.height / 2;
//     final r  = size.width  / 2;

//     final paint = Paint()..color = color..style = PaintingStyle.fill;

//     // Organic control-point offsets (blob shape at morphProgress = 0)
//     // These describe a roughly heart/cloud-like blob
//     final organicPath = _buildOrganicPath(cx, cy, r);
//     final circlePath  = _buildCirclePath(cx, cy, r);

//     // Simple lerp: at morphProgress=0 draw organic, at 1 draw circle.
//     // We achieve the morph by interpolating the path metrics via
//     // drawing with a lerped clip radius + the organic path fading.
//     if (morphProgress < 0.01) {
//       canvas.drawPath(organicPath, paint);
//     } else if (morphProgress > 0.99) {
//       canvas.drawCircle(Offset(cx, cy), r, paint);
//     } else {
//       // Draw organic path but clip expanding circle over it to morph
//       canvas.save();
//       canvas.drawPath(organicPath, paint);
//       // Expanding circle overlay same color — creates a smooth morph
//       canvas.drawCircle(
//         Offset(cx, cy),
//         r * morphProgress,
//         paint,
//       );
//       canvas.restore();
//     }
//   }

//   // Organic blob path — tuned to match the video's heart-cloud shape
//   Path _buildOrganicPath(double cx, double cy, double r) {
//     final path = Path();
//     // Control points as fraction of radius
//     // Top-left lobe
//     path.moveTo(cx - r * 0.10, cy - r * 0.85);
//     path.cubicTo(
//       cx - r * 0.55, cy - r * 1.05,
//       cx - r * 1.00, cy - r * 0.60,
//       cx - r * 0.95, cy - r * 0.10,
//     );
//     // Left side dip
//     path.cubicTo(
//       cx - r * 0.90, cy + r * 0.30,
//       cx - r * 0.60, cy + r * 0.55,
//       cx,            cy + r * 0.70,
//     );
//     // Bottom point
//     path.cubicTo(
//       cx + r * 0.60, cy + r * 0.55,
//       cx + r * 0.85, cy + r * 0.25,
//       cx + r * 0.95, cy - r * 0.05,
//     );
//     // Right side back to top-right
//     path.cubicTo(
//       cx + r * 1.05, cy - r * 0.50,
//       cx + r * 0.65, cy - r * 0.95,
//       cx + r * 0.20, cy - r * 0.90,
//     );
//     // Top connection back to start
//     path.cubicTo(
//       cx + r * 0.00, cy - r * 0.85,
//       cx - r * 0.00, cy - r * 0.85,
//       cx - r * 0.10, cy - r * 0.85,
//     );
//     path.close();
//     return path;
//   }

//   Path _buildCirclePath(double cx, double cy, double r) {
//     return Path()
//       ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
//   }

//   @override
//   bool shouldRepaint(_BlobPainter old) =>
//       old.morphProgress != morphProgress || old.color != color;
// }

// // ─────────────────────────────────────────────────────────────────
// //  CORNER WIPE PAINTER  –  white rounded sheet from bottom-right
// // ─────────────────────────────────────────────────────────────────
// class _CornerWipePainter extends CustomPainter {
//   final double progress; // 0 → 1
//   final Color  color;

//   const _CornerWipePainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     // The wipe is a large circle whose centre starts at the
//     // bottom-right corner and whose radius grows until it covers
//     // the entire screen — classic "corner reveal" transition.
//     final maxRadius = math.sqrt(
//       size.width * size.width + size.height * size.height,
//     );

//     final center = Offset(size.width, size.height); // bottom-right
//     final radius = maxRadius * progress;

//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;

//     canvas.drawCircle(center, radius, paint);
//   }

//   @override
//   bool shouldRepaint(_CornerWipePainter old) =>
//       old.progress != progress || old.color != color;
// }

// // ─────────────────────────────────────────────────────────────────
// //  ICON TRELLIS PAINTER  –  repeating food icons on white bg
// // ─────────────────────────────────────────────────────────────────
// class _IconTrellisPainter extends CustomPainter {
//   final Color color;
//   const _IconTrellisPainter({required this.color});

//   // We draw simple geometric stand-ins for food icons.
//   // Replace with actual SVG/asset icons if desired.
//   static const _icons = [
//     _IconType.croissant,
//     _IconType.cake,
//     _IconType.bread,
//     _IconType.muffin,
//     _IconType.cookie,
//     _IconType.tart,
//   ];

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color       = color
//       ..style       = PaintingStyle.stroke
//       ..strokeWidth = 1.4
//       ..strokeCap   = StrokeCap.round
//       ..strokeJoin  = StrokeJoin.round;

//     const cellSize = 90.0;
//     final cols = (size.width  / cellSize).ceil() + 1;
//     final rows = (size.height / cellSize).ceil() + 1;

//     for (int row = 0; row < rows; row++) {
//       for (int col = 0; col < cols; col++) {
//         final cx = col * cellSize + (row.isOdd ? cellSize / 2 : 0);
//         final cy = row * cellSize * 0.85;
//         final iconType = _icons[(row * cols + col) % _icons.length];
//         _drawIcon(canvas, paint, Offset(cx, cy), 18, iconType);
//       }
//     }
//   }

//   void _drawIcon(
//     Canvas canvas, Paint paint, Offset center, double size, _IconType type,
// ) {
//     canvas.save();
//     canvas.translate(center.dx, center.dy);

//     switch (type) {
//       case _IconType.croissant:
//         _drawCroissant(canvas, paint, size);
//       case _IconType.cake:
//         _drawCake(canvas, paint, size);
//       case _IconType.bread:
//         _drawBread(canvas, paint, size);
//       case _IconType.muffin:
//         _drawMuffin(canvas, paint, size);
//       case _IconType.cookie:
//         _drawCookie(canvas, paint, size);
//       case _IconType.tart:
//         _drawTart(canvas, paint, size);
//     }

//     canvas.restore();
//   }

//   void _drawCroissant(Canvas canvas, Paint p, double s) {
//     final path = Path()
//       ..moveTo(-s, 0)
//       ..cubicTo(-s * 0.5, -s * 0.8,  s * 0.5, -s * 0.8,  s, 0)
//       ..cubicTo( s * 0.6,  s * 0.3, -s * 0.6,  s * 0.3, -s, 0);
//     canvas.drawPath(path, p);
//     canvas.drawLine(Offset(0, -s * 0.3), Offset(0, s * 0.2), p);
//   }

//   void _drawCake(Canvas canvas, Paint p, double s) {
//     // Rectangle body
//     canvas.drawRect(Rect.fromCenter(center: Offset(0, s * 0.2), width: s * 1.6, height: s * 1.0), p);
//     // Candle
//     canvas.drawLine(Offset(0, -s * 0.3), Offset(0, -s * 0.8), p);
//     // Flame
//     canvas.drawOval(Rect.fromCenter(center: Offset(0, -s * 0.95), width: s * 0.25, height: s * 0.3), p);
//   }

//   void _drawBread(Canvas canvas, Paint p, double s) {
//     canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 1.8, height: s * 1.2), p);
//     // Score lines
//     canvas.drawLine(Offset(-s * 0.4, -s * 0.1), Offset(-s * 0.4, s * 0.3), p);
//     canvas.drawLine(Offset( s * 0.4, -s * 0.1), Offset( s * 0.4, s * 0.3), p);
//   }

//   void _drawMuffin(Canvas canvas, Paint p, double s) {
//     // Cup
//     final cup = Path()
//       ..moveTo(-s * 0.7, s * 0.8)
//       ..lineTo(-s * 0.5, s * 0.0)
//       ..lineTo( s * 0.5, s * 0.0)
//       ..lineTo( s * 0.7, s * 0.8)
//       ..close();
//     canvas.drawPath(cup, p);
//     // Top dome
//     canvas.drawArc(
//       Rect.fromCenter(center: Offset(0, s * 0.0), width: s * 1.4, height: s * 1.0),
//       math.pi, math.pi, false, p,
//     );
//   }

//   void _drawCookie(Canvas canvas, Paint p, double s) {
//     canvas.drawCircle(Offset.zero, s * 0.8, p);
//     // Chocolate chips
//     for (int i = 0; i < 5; i++) {
//       final angle = i * math.pi * 2 / 5;
//       canvas.drawCircle(
//         Offset(math.cos(angle) * s * 0.4, math.sin(angle) * s * 0.4),
//         s * 0.12, p..style = PaintingStyle.fill,
//       );
//     }
//     p.style = PaintingStyle.stroke;
//   }

//   void _drawTart(Canvas canvas, Paint p, double s) {
//     // Tart shell
//     canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.1), width: s * 1.6, height: s * 0.7), p);
//     // Inner filling dome
//     canvas.drawArc(
//       Rect.fromCenter(center: Offset(0, s * 0.1), width: s * 1.2, height: s * 0.9),
//       math.pi, math.pi, false, p,
//     );
//     // Decorative berry
//     canvas.drawCircle(Offset(0, -s * 0.3), s * 0.2, p..style = PaintingStyle.fill);
//     p.style = PaintingStyle.stroke;
//   }

//   @override
//   bool shouldRepaint(_IconTrellisPainter old) => old.color != color;
// }

// enum _IconType { croissant, cake, bread, muffin, cookie, tart }


// // ─────────────────────────────────────────────────────────────────
// //  DEMO RUNNER  –  drop this in main.dart to preview
// // ─────────────────────────────────────────────────────────────────
// void main() {
//   runApp(const _DemoApp());
// }

// class _DemoApp extends StatelessWidget {
//   const _DemoApp();
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: '',
//       home: SplashScreen(
//         onFinished: () {
//           Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
          
//         },
//       ),
//     );
//   }
// }


// import 'dart:math' as math;
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';

// // ─────────────────────────────────────────────────────────────────
// //  OPHICINA  –  Splash Screen
// //
// //  Visual sequence (slowed down):
// //
// //   0 ms        White/cream bg — organic green blob centred
// //               with logo PNG + "Ophicina" + tagline on top
// //   0–900 ms    Hold so user reads the logo
// //   900 ms      Blob starts expanding (1 400 ms)
// //   2 400 ms    Cream corner wipe sweeps from bottom-right (900 ms)
// //   3 400 ms    "Ophicina" title slides up on cream bg (900 ms)
// //   4 000 ms    Tagline fades in (800 ms)
// //   5 200 ms    Navigation fires (after auth resolves)
// //
// //  Auth/navigation: identical to the original SplashScreen.
// // ─────────────────────────────────────────────────────────────────

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {

//   // ── Blob expand + morph ───────────────────────────────────────
//   late AnimationController _blobCtrl;
//   late Animation<double>   _blobScale;
//   late Animation<double>   _blobMorph;

//   // ── Corner wipe ───────────────────────────────────────────────
//   late AnimationController _wipeCtrl;
//   late Animation<double>   _wipeProgress;

//   // ── Post-wipe title ───────────────────────────────────────────
//   late AnimationController _titleCtrl;
//   late Animation<double>   _titleFade;
//   late Animation<Offset>   _titleSlide;

//   // ── Post-wipe tagline ─────────────────────────────────────────
//   late AnimationController _taglineCtrl;
//   late Animation<double>   _taglineFade;

//   // ── Auth / navigation ─────────────────────────────────────────
//   bool _splashFinished = false;
//   bool _navigated      = false;
//   late AuthProvider _authProvider;

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _runSequence();
//   }

//   void _initAnimations() {
//     // 1. Blob expand — 1 400 ms, slow + cinematic
//     _blobCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );
//     _blobScale = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeInOutCubic,
//     );
//     _blobMorph = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeIn,
//     );

//     // 2. Corner wipe — 900 ms
//     _wipeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _wipeProgress = CurvedAnimation(
//       parent: _wipeCtrl,
//       curve: Curves.easeInOutQuart,
//     );

//     // 3. Title slide-up — 900 ms
//     _titleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _titleFade  = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);
//     _titleSlide = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end:   Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic),
//     );

//     // 4. Tagline fade — 800 ms
//     _taglineCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _taglineFade =
//         CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);
//   }

//   Future<void> _runSequence() async {
//     // Hold — let user see the logo on the blob
//     await Future.delayed(const Duration(milliseconds: 900));

//     // Blob fills the screen
//     await _blobCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 100));

//     // Cream corner wipe reveals white bg
//     await _wipeCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 200));

//     // Title then tagline appear
//     _titleCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 600));
//     _taglineCtrl.forward();

//     // Hold before navigating
//     await Future.delayed(const Duration(milliseconds: 1400));

//     _splashFinished = true;
//     _tryNavigate();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   void _tryNavigate() {
//     if (!mounted || _navigated) return;
//     final auth = context.read<AuthProvider>();
//     if (auth.isLoading || !_splashFinished) return;
//     _navigated = true;
//     final user = auth.user;
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final profile = await AdminRepository().getByUid(user.userId);
//         if (!mounted) return;
//         if (profile == null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const AdminAccountScreen(mode: AdminFormMode.create),
//             ),
//           );
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const RecruiterAccountScreen(
//                   mode: AccountFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const JobSeekerAccountScreen(
//                   mode: JobSeekerFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(
//                 context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void dispose() {
//     _authProvider.removeListener(_tryNavigate);
//     _blobCtrl.dispose();
//     _wipeCtrl.dispose();
//     _titleCtrl.dispose();
//     _taglineCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: AppColors.beigeWhite,
//       body: AnimatedBuilder(
//         animation: Listenable.merge(
//             [_blobCtrl, _wipeCtrl, _titleCtrl, _taglineCtrl]),
//         builder: (context, _) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [

//               // Layer 1 — expanding green blob
//               _buildBlob(size),

//               // Layer 2 — logo + name + tagline on the blob
//               //            fades out as the wipe covers it
//               _buildBlobContent(),

//               // Layer 3 — cream corner wipe
//               if (_wipeCtrl.value > 0)
//                 _buildCornerWipe(size),

//               // Layer 4 — post-wipe branding on cream background
//               if (_titleCtrl.value > 0)
//                 _buildPostWipeContent(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // ── Expanding organic blob ────────────────────────────────────
//   Widget _buildBlob(Size size) {
//     final maxDim =
//         math.sqrt(size.width * size.width + size.height * size.height) * 1.05;
//     const fraction = 0.58;
//     final baseD       = size.width * fraction;
//     final targetScale = maxDim / baseD;
//     final scale       = 1.0 + _blobScale.value * (targetScale - 1.0);

//     return Center(
//       child: Transform.scale(
//         scale: scale,
//         child: SizedBox(
//           width:  baseD,
//           height: baseD,
//           child: CustomPaint(
//             painter: _BlobPainter(
//               color:         AppColors.greenCeladon,
//               morphProgress: _blobMorph.value,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Branding layer shown on top of the green blob ─────────────
//   Widget _buildBlobContent() {
//     // Fade out cleanly as the corner wipe rolls over this layer
//     final alpha = _wipeProgress.value < 0.40
//         ? 1.0
//         : 1.0 - ((_wipeProgress.value - 0.40) / 0.60).clamp(0.0, 1.0);

//     return Opacity(
//       opacity: alpha,
//       child: Align(
//         alignment: const Alignment(0, -0.12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [

//             // ── Logo PNG ────────────────────────────────────────
//             SizedBox(
//               width:  110,
//               height: 110,
//               child: ClipOval(
//                 child: Image.asset(
//                   // ← set your real path in pubspec.yaml:
//                   //   assets/images/ophicina_logo.png
//                   'assets/images/ophicina_logo.png',
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => _LogoFallback(
//                     size:        110,
//                     letter:      'O',
//                     letterColor: AppColors.greenCeladon,
//                     colors:      [AppColors.beigeWhite, AppColors.pinkO],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 22),

//             // ── App name ────────────────────────────────────────
//             Text(
//               'Ophicina',
//               style: TextStyle(
//                 fontSize:      40,
//                 letterSpacing: 2.6,
//                 fontWeight:    FontWeight.w600,
//                 color:         AppColors.white,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // ── Tagline ─────────────────────────────────────────
//             Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      15,
//                 letterSpacing: 1.4,
//                 color:         AppColors.white.withOpacity(0.85),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Cream corner wipe ─────────────────────────────────────────
//   Widget _buildCornerWipe(Size size) {
//     return CustomPaint(
//       size: size,
//       painter: _CornerWipePainter(
//         progress: _wipeProgress.value,
//         color:    AppColors.beigeWhite,
//       ),
//     );
//   }

//   // ── Post-wipe branding on cream/white ─────────────────────────
//   Widget _buildPostWipeContent() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [

//           // ── Logo (same PNG, now on light background) ─────────
//           SizedBox(
//             width:  100,
//             height: 100,
//             child: ClipOval(
//               child: Image.asset(
//                 'assets/icon/app_icon.png',
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => _LogoFallback(
//                   size:        100,
//                   letter:      'O',
//                   letterColor: AppColors.greenCeladon,
//                   colors:      [AppColors.beigeWhite, AppColors.pinkO],
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // ── Title slides up ──────────────────────────────────
//           FadeTransition(
//             opacity: _titleFade,
//             child: SlideTransition(
//               position: _titleSlide,
//               child: Text(
//                 'Ophicina',
//                 style: TextStyle(
//                   fontSize:      40,
//                   letterSpacing: 2.6,
//                   fontWeight:    FontWeight.w600,
//                   color:         AppColors.greenCeladon,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ── Tagline fades in ─────────────────────────────────
//           FadeTransition(
//             opacity: _taglineFade,
//             child: Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      15,
//                 letterSpacing: 1.4,
//                 color:         AppColors.greenCeladon.withOpacity(0.70),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  LOGO FALLBACK
// //  Shown when the PNG asset isn't configured yet.
// //  Once you add 'assets/images/ophicina_logo.png' to pubspec.yaml
// //  and drop the file in, Image.asset will use it automatically.
// // ─────────────────────────────────────────────────────────────────
// class _LogoFallback extends StatelessWidget {
//   final double      size;
//   final String      letter;
//   final Color       letterColor;
//   final List<Color> colors;

//   const _LogoFallback({
//     required this.size,
//     required this.letter,
//     required this.letterColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width:  size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end:   Alignment.bottomRight,
//           colors: colors,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           letter,
//           style: TextStyle(
//             fontSize:   size * 0.60,
//             fontWeight: FontWeight.w700,
//             height:     1,
//             color:      letterColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  BLOB PAINTER
// //  Organic rounded shape that morphs into a full circle
// //  as it scales up to fill the screen.
// // ─────────────────────────────────────────────────────────────────
// class _BlobPainter extends CustomPainter {
//   final Color  color;
//   final double morphProgress; // 0 = organic, 1 = circle

//   const _BlobPainter({required this.color, required this.morphProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width  / 2;
//     final cy = size.height / 2;
//     final r  = size.width  / 2;
//     final paint = Paint()..color = color..style = PaintingStyle.fill;

//     if (morphProgress < 0.01) {
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//     } else if (morphProgress > 0.99) {
//       canvas.drawCircle(Offset(cx, cy), r, paint);
//     } else {
//       // Organic blob + expanding circle overlay → smooth morph
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//       canvas.drawCircle(Offset(cx, cy), r * morphProgress, paint);
//     }
//   }

//   Path _organicPath(double cx, double cy, double r) {
//     return Path()
//       ..moveTo(cx - r * 0.10, cy - r * 0.85)
//       ..cubicTo(
//           cx - r * 0.55, cy - r * 1.05,
//           cx - r * 1.00, cy - r * 0.60,
//           cx - r * 0.95, cy - r * 0.10)
//       ..cubicTo(
//           cx - r * 0.90, cy + r * 0.30,
//           cx - r * 0.60, cy + r * 0.55,
//           cx,            cy + r * 0.70)
//       ..cubicTo(
//           cx + r * 0.60, cy + r * 0.55,
//           cx + r * 0.85, cy + r * 0.25,
//           cx + r * 0.95, cy - r * 0.05)
//       ..cubicTo(
//           cx + r * 1.05, cy - r * 0.50,
//           cx + r * 0.65, cy - r * 0.95,
//           cx + r * 0.20, cy - r * 0.90)
//       ..cubicTo(
//           cx,            cy - r * 0.85,
//           cx,            cy - r * 0.85,
//           cx - r * 0.10, cy - r * 0.85)
//       ..close();
//   }

//   @override
//   bool shouldRepaint(_BlobPainter old) =>
//       old.morphProgress != morphProgress || old.color != color;
// }

// // ─────────────────────────────────────────────────────────────────
// //  CORNER WIPE PAINTER
// //  A cream-coloured circle grows from the bottom-right corner
// //  until it covers the entire screen.
// // ─────────────────────────────────────────────────────────────────
// class _CornerWipePainter extends CustomPainter {
//   final double progress;
//   final Color  color;

//   const _CornerWipePainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final maxRadius =
//         math.sqrt(size.width * size.width + size.height * size.height);
//     canvas.drawCircle(
//       Offset(size.width, size.height), // bottom-right corner origin
//       maxRadius * progress,
//       Paint()..color = color,
//     );
//   }

//   @override
//   bool shouldRepaint(_CornerWipePainter old) =>
//       old.progress != progress || old.color != color;
// }


// import 'dart:math' as math;
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';


// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {

//   // ── Blob expand + morph ───────────────────────────────────────
//   late AnimationController _blobCtrl;
//   late Animation<double>   _blobScale;
//   late Animation<double>   _blobMorph;

//   // ── Corner wipe ───────────────────────────────────────────────
//   late AnimationController _wipeCtrl;
//   late Animation<double>   _wipeProgress;

//   // ── Post-wipe title ───────────────────────────────────────────
//   late AnimationController _titleCtrl;
//   late Animation<double>   _titleFade;
//   late Animation<Offset>   _titleSlide;

//   // ── Post-wipe tagline ─────────────────────────────────────────
//   late AnimationController _taglineCtrl;
//   late Animation<double>   _taglineFade;

//   // ── Auth / navigation ─────────────────────────────────────────
//   bool _splashFinished = false;
//   bool _navigated      = false;
//   late AuthProvider _authProvider;

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _runSequence();
//   }

//   void _initAnimations() {
//     // 1. Blob expand — 1 400 ms, slow + cinematic
//     _blobCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );
//     _blobScale = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeInOutCubic,
//     );
//     _blobMorph = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeIn,
//     );

//     // 2. Corner wipe — 900 ms
//     _wipeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _wipeProgress = CurvedAnimation(
//       parent: _wipeCtrl,
//       curve: Curves.easeInOutQuart,
//     );

//     // 3. Title slide-up — 900 ms
//     _titleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _titleFade  = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);
//     _titleSlide = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end:   Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic),
//     );

//     // 4. Tagline fade — 800 ms
//     _taglineCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _taglineFade =
//         CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);
//   }

//   Future<void> _runSequence() async {
//     // Hold — let user see the logo on the blob
//     await Future.delayed(const Duration(milliseconds: 900));

//     // Blob fills the screen
//     await _blobCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 100));

//     // Cream corner wipe reveals white bg
//     await _wipeCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 200));

//     // Title then tagline appear
//     _titleCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 600));
//     _taglineCtrl.forward();

//     // Hold before navigating
//     await Future.delayed(const Duration(milliseconds: 1400));

//     _splashFinished = true;
//     _tryNavigate();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   void _tryNavigate() {
//     if (!mounted || _navigated) return;
//     final auth = context.read<AuthProvider>();
//     if (auth.isLoading || !_splashFinished) return;
//     _navigated = true;
//     final user = auth.user;
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final profile = await AdminRepository().getByUid(user.userId);
//         if (!mounted) return;
//         if (profile == null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const AdminAccountScreen(mode: AdminFormMode.create),
//             ),
//           );
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const RecruiterAccountScreen(
//                   mode: AccountFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const JobSeekerAccountScreen(
//                   mode: JobSeekerFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(
//                 context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void dispose() {
//     _authProvider.removeListener(_tryNavigate);
//     _blobCtrl.dispose();
//     _wipeCtrl.dispose();
//     _titleCtrl.dispose();
//     _taglineCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: AnimatedBuilder(
//         animation: Listenable.merge(
//             [_blobCtrl, _wipeCtrl, _titleCtrl, _taglineCtrl]),
//         builder: (context, _) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [

//               // Layer 1 — expanding green blob
//               _buildBlob(size),

//               // Layer 2 — logo + name + tagline on the blob
//               //            fades out as the wipe covers it
//               _buildBlobContent(),

//               // Layer 3 — cream corner wipe
//               if (_wipeCtrl.value > 0)
//                 _buildCornerWipe(size),

//               // Layer 4 — post-wipe branding on cream background
//               if (_titleCtrl.value > 0)
//                 _buildPostWipeContent(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // ── Expanding organic blob ────────────────────────────────────
//   Widget _buildBlob(Size size) {
//     final maxDim =
//         math.sqrt(size.width * size.width + size.height * size.height) * 1.05;
//     const fraction = 0.58;
//     final baseD       = size.width * fraction;
//     final targetScale = maxDim / baseD;
//     final scale       = 1.0 + _blobScale.value * (targetScale - 1.0);

//     return Center(
//       child: Transform.scale(
//         scale: scale,
//         child: SizedBox(
//           width:  baseD,
//           height: baseD,
//           child: CustomPaint(
//             painter: _BlobPainter(
//               color:         AppColors.greenCeladon,
//               morphProgress: _blobMorph.value,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Branding layer shown on top of the green blob ─────────────
//   Widget _buildBlobContent() {
//     // Fade out cleanly as the corner wipe rolls over this layer
//     final alpha = _wipeProgress.value < 0.40
//         ? 1.0
//         : 1.0 - ((_wipeProgress.value - 0.40) / 0.60).clamp(0.0, 1.0);

//     return Opacity(
//       opacity: alpha,
//       child: Align(
//         alignment: const Alignment(0, -0.12),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [

//             // ── Logo PNG ────────────────────────────────────────
//             SizedBox(
//               width:  110,
//               height: 110,
//               child: Image.asset(
//                 'assets/icon/app_icon.png',
//                 fit: BoxFit.contain,
//                 errorBuilder: (_, __, ___) => _LogoFallback(
//                   size:        110,
//                   letter:      'O',
//                   letterColor: AppColors.white,
//                   colors:      [AppColors.greenCeladon, AppColors.greenCeladon],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 22),

//             // ── App name ────────────────────────────────────────
//             Text(
//               'Ophicina',
//               style: TextStyle(
//                 fontSize:      40,
//                 letterSpacing: 2.6,
//                 fontWeight:    FontWeight.w600,
//                 color:         AppColors.white,
//               ),
//             ),

//             const SizedBox(height: 10),

//             // ── Tagline ─────────────────────────────────────────
//             Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      15,
//                 letterSpacing: 1.4,
//                 color:         AppColors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Cream corner wipe ─────────────────────────────────────────
//   Widget _buildCornerWipe(Size size) {
//     return CustomPaint(
//       size: size,
//       painter: _CornerWipePainter(
//         progress: _wipeProgress.value,
//         color:    AppColors.white,
//       ),
//     );
//   }

//   // ── Post-wipe branding on cream/white ─────────────────────────
//   Widget _buildPostWipeContent() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [

//           // ── Logo (same PNG, now on light background) ─────────
//           SizedBox(
//             width:  100,
//             height: 100,
//             child: Image.asset(
//               'assets/icon/app_icon.png',
//               fit: BoxFit.contain,
//               errorBuilder: (_, __, ___) => _LogoFallback(
//                 size:        100,
//                 letter:      'O',
//                 letterColor: AppColors.greenCeladon,
//                 colors:      [AppColors.white, AppColors.greenCeladon],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // ── Title slides up ──────────────────────────────────
//           FadeTransition(
//             opacity: _titleFade,
//             child: SlideTransition(
//               position: _titleSlide,
//               child: Text(
//                 'Ophicina',
//                 style: TextStyle(
//                   fontSize:      40,
//                   letterSpacing: 2.6,
//                   fontWeight:    FontWeight.w600,
//                   color:         AppColors.greenCeladon,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ── Tagline fades in ─────────────────────────────────
//           FadeTransition(
//             opacity: _taglineFade,
//             child: Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      15,
//                 letterSpacing: 1.4,
//                 color:         AppColors.greenCeladon.withOpacity(0.70),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  LOGO FALLBACK
// //  Shown when the PNG asset isn't configured yet.
// //  Once you add 'assets/images/ophicina_logo.png' to pubspec.yaml
// //  and drop the file in, Image.asset will use it automatically.
// // ─────────────────────────────────────────────────────────────────
// class _LogoFallback extends StatelessWidget {
//   final double size;
//   final String letter;
//   final Color  letterColor;
//   final List<Color> colors; // kept for API compat, only first color used

//   const _LogoFallback({
//     required this.size,
//     required this.letter,
//     required this.letterColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width:  size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: colors.first,
//       ),
//       child: Center(
//         child: Text(
//           letter,
//           style: TextStyle(
//             fontSize:   size * 0.60,
//             fontWeight: FontWeight.w700,
//             height:     1,
//             color:      letterColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  BLOB PAINTER
// //  Organic rounded shape that morphs into a full circle
// //  as it scales up to fill the screen.
// // ─────────────────────────────────────────────────────────────────
// class _BlobPainter extends CustomPainter {
//   final Color  color;
//   final double morphProgress; // 0 = organic, 1 = circle

//   const _BlobPainter({required this.color, required this.morphProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width  / 2;
//     final cy = size.height / 2;
//     final r  = size.width  / 2;
//     final paint = Paint()..color = color..style = PaintingStyle.fill;

//     if (morphProgress < 0.01) {
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//     } else if (morphProgress > 0.99) {
//       canvas.drawCircle(Offset(cx, cy), r, paint);
//     } else {
//       // Organic blob + expanding circle overlay → smooth morph
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//       canvas.drawCircle(Offset(cx, cy), r * morphProgress, paint);
//     }
//   }

//   Path _organicPath(double cx, double cy, double r) {
//     return Path()
//       ..moveTo(cx - r * 0.10, cy - r * 0.85)
//       ..cubicTo(
//           cx - r * 0.55, cy - r * 1.05,
//           cx - r * 1.00, cy - r * 0.60,
//           cx - r * 0.95, cy - r * 0.10)
//       ..cubicTo(
//           cx - r * 0.90, cy + r * 0.30,
//           cx - r * 0.60, cy + r * 0.55,
//           cx,            cy + r * 0.70)
//       ..cubicTo(
//           cx + r * 0.60, cy + r * 0.55,
//           cx + r * 0.85, cy + r * 0.25,
//           cx + r * 0.95, cy - r * 0.05)
//       ..cubicTo(
//           cx + r * 1.05, cy - r * 0.50,
//           cx + r * 0.65, cy - r * 0.95,
//           cx + r * 0.20, cy - r * 0.90)
//       ..cubicTo(
//           cx,            cy - r * 0.85,
//           cx,            cy - r * 0.85,
//           cx - r * 0.10, cy - r * 0.85)
//       ..close();
//   }

//   @override
//   bool shouldRepaint(_BlobPainter old) =>
//       old.morphProgress != morphProgress || old.color != color;
// }

// // ─────────────────────────────────────────────────────────────────
// //  CORNER WIPE PAINTER
// //  A cream-coloured circle grows from the bottom-right corner
// //  until it covers the entire screen.
// // ─────────────────────────────────────────────────────────────────
// class _CornerWipePainter extends CustomPainter {
//   final double progress;
//   final Color  color;

//   const _CornerWipePainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final maxRadius =
//         math.sqrt(size.width * size.width + size.height * size.height);
//     canvas.drawCircle(
//       Offset(size.width, size.height), // bottom-right corner origin
//       maxRadius * progress,
//       Paint()..color = color,
//     );
//   }

//   @override
//   bool shouldRepaint(_CornerWipePainter old) =>
//       old.progress != progress || old.color != color;
// }

// import 'dart:math' as math;
// import 'package:client/AdminPannel/AdminAccountScreen.dart';
// import 'package:client/AdminPannel/BlockedScreen.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
// import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
// import 'package:client/Server/Enums/AdminEnum.dart';
// import 'package:client/Server/Enums/JobSeekerEnum.dart';
// import 'package:client/Server/Enums/Recruiterenum.dart';
// import 'package:client/Server/Enums/UserRole.dart';
// import 'package:client/Server/Model/AppUser.dart';
// import 'package:client/Server/Repo/AdminRepo.dart';
// import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
// import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
// import 'package:flutter/material.dart';
// import 'package:client/routes/app_routes.dart';
// import 'package:client/AppColors/AppColors.dart';
// import 'package:provider/provider.dart';


// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {

//   // ── Blob expand + morph ───────────────────────────────────────
//   late AnimationController _blobCtrl;
//   late Animation<double>   _blobScale;
//   late Animation<double>   _blobMorph;

//   // ── Corner wipe ───────────────────────────────────────────────
//   late AnimationController _wipeCtrl;
//   late Animation<double>   _wipeProgress;

//   // ── Post-wipe title ───────────────────────────────────────────
//   late AnimationController _titleCtrl;
//   late Animation<double>   _titleFade;
//   late Animation<Offset>   _titleSlide;

//   // ── Post-wipe tagline ─────────────────────────────────────────
//   late AnimationController _taglineCtrl;
//   late Animation<double>   _taglineFade;

//   // ── Auth / navigation ─────────────────────────────────────────
//   bool _splashFinished = false;
//   bool _navigated      = false;
//   late AuthProvider _authProvider;

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//     _runSequence();
//   }

//   void _initAnimations() {
//     // 1. Blob expand — 1 400 ms, slow + cinematic
//     _blobCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1400),
//     );
//     _blobScale = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeInOutCubic,
//     );
//     _blobMorph = CurvedAnimation(
//       parent: _blobCtrl,
//       curve: Curves.easeIn,
//     );

//     // 2. Corner wipe — 900 ms
//     _wipeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _wipeProgress = CurvedAnimation(
//       parent: _wipeCtrl,
//       curve: Curves.easeInOutQuart,
//     );

//     // 3. Title slide-up — 900 ms
//     _titleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _titleFade  = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);
//     _titleSlide = Tween<Offset>(
//       begin: const Offset(0, 0.5),
//       end:   Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic),
//     );

//     // 4. Tagline fade — 800 ms
//     _taglineCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//     _taglineFade =
//         CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);
//   }

//   Future<void> _runSequence() async {
//     // Hold — let user see the logo on the blob
//     await Future.delayed(const Duration(milliseconds: 900));

//     // Blob fills the screen
//     await _blobCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 100));

//     // Cream corner wipe reveals white bg
//     await _wipeCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 200));

//     // Title then tagline appear
//     _titleCtrl.forward();
//     await Future.delayed(const Duration(milliseconds: 600));
//     _taglineCtrl.forward();

//     // Hold before navigating
//     await Future.delayed(const Duration(milliseconds: 1400));

//     _splashFinished = true;
//     _tryNavigate();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _authProvider = context.read<AuthProvider>();
//     _authProvider.addListener(_tryNavigate);
//   }

//   void _tryNavigate() {
//     if (!mounted || _navigated) return;
//     final auth = context.read<AuthProvider>();
//     if (auth.isLoading || !_splashFinished) return;
//     _navigated = true;
//     final user = auth.user;
//     if (user == null) {
//       Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
//     } else {
//       _navigateBasedOnRole(user);
//     }
//   }

//   Future<void> _navigateBasedOnRole(AppUser user) async {
//     final recruiterRepo = RecruiterRepository();
//     final jobSeekerRepo = JobSeekerRepository();

//     switch (user.role) {
//       case UserRole.admin:
//         final profile = await AdminRepository().getByUid(user.userId);
//         if (!mounted) return;
//         if (profile == null) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   const AdminAccountScreen(mode: AdminFormMode.create),
//             ),
//           );
//         } else {
//           Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
//         }
//         break;

//       case UserRole.recruiter:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await recruiterRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const RecruiterAccountScreen(
//                   mode: AccountFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
//           }
//         }
//         break;

//       case UserRole.jobSeeker:
//         if (user.isBlocked) {
//           if (!mounted) return;
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
//           );
//         } else {
//           final profile = await jobSeekerRepo.getByUid(user.userId);
//           if (!mounted) return;
//           if (profile == null) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const JobSeekerAccountScreen(
//                   mode: JobSeekerFormMode.create,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.pushReplacementNamed(
//                 context, AppRoutes.jobSeekerDash);
//           }
//         }
//         break;
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   void dispose() {
//     _authProvider.removeListener(_tryNavigate);
//     _blobCtrl.dispose();
//     _wipeCtrl.dispose();
//     _titleCtrl.dispose();
//     _taglineCtrl.dispose();
//     super.dispose();
//   }

//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: AnimatedBuilder(
//         animation: Listenable.merge(
//             [_blobCtrl, _wipeCtrl, _titleCtrl, _taglineCtrl]),
//         builder: (context, _) {
//           return Stack(
//             fit: StackFit.expand,
//             children: [

//               // Layer 1 — expanding green blob
//               _buildBlob(size),

//               // Layer 2 — logo + name + tagline on the blob
//               //            fades out as the wipe covers it
//               _buildBlobContent(),

//               // Layer 3 — cream corner wipe
//               if (_wipeCtrl.value > 0)
//                 _buildCornerWipe(size),

//               // Layer 4 — post-wipe branding on white background
//               if (_titleCtrl.value > 0)
//                 _buildPostWipeContent(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // ── Expanding organic blob ────────────────────────────────────
//   Widget _buildBlob(Size size) {
//     final maxDim =
//         math.sqrt(size.width * size.width + size.height * size.height) * 1.05;
//     const fraction = 0.82; // was 0.58 — starts much bigger, wraps text nicely
//     final baseD       = size.width * fraction;
//     final targetScale = maxDim / baseD;
//     final scale       = 1.0 + _blobScale.value * (targetScale - 1.0);

//     return Center(
//       child: Transform.scale(
//         scale: scale,
//         child: SizedBox(
//           width:  baseD,
//           height: baseD,
//           child: CustomPaint(
//             painter: _BlobPainter(
//               color:         AppColors.greenCeladon,
//               morphProgress: _blobMorph.value,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Branding layer shown on top of the green blob ─────────────
//   Widget _buildBlobContent() {
//     // Fade out cleanly as the corner wipe rolls over this layer
//     final alpha = _wipeProgress.value < 0.40
//         ? 1.0
//         : 1.0 - ((_wipeProgress.value - 0.40) / 0.60).clamp(0.0, 1.0);

//     return Opacity(
//       opacity: alpha,
//       child: Align(
//         alignment: const Alignment(0, -0.18),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [

//             // ── Logo PNG ────────────────────────────────────────
//             // SizedBox(
//             //   width:  140, // was 110
//             //   height: 140, // was 110
//             //   child: Image.asset(
//             //     'assets/logoOphicina.png',
//             //     fit: BoxFit.contain,
//             //     errorBuilder: (_, __, ___) => _LogoFallback(
//             //       size:        140,
//             //       letter:      'O',
//             //       letterColor: AppColors.white,
//             //       colors:      [AppColors.greenCeladon, AppColors.greenCeladon],
//             //     ),
//             //   ),
//             // ),

//             // const SizedBox(height: 28), // was 22

//             // ── App name ────────────────────────────────────────
//             Text(
//               'Ophicina',
//               style: TextStyle(
//                 fontSize:      44, // was 40
//                 letterSpacing: 2.6,
//                 fontWeight:    FontWeight.w600,
//                 color:         AppColors.white,
//               ),
//             ),

//             const SizedBox(height: 12),

//             // ── Tagline ─────────────────────────────────────────
//             Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      15,
//                 letterSpacing: 1.4,
//                 color:         AppColors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Cream corner wipe ─────────────────────────────────────────
//   Widget _buildCornerWipe(Size size) {
//     return CustomPaint(
//       size: size,
//       painter: _CornerWipePainter(
//         progress: _wipeProgress.value,
//         color:    AppColors.white,
//       ),
//     );
//   }

//   // ── Post-wipe branding on white background ────────────────────
//   Widget _buildPostWipeContent() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [

//           // ── Logo (larger, on light background) ───────────────
//           SizedBox(
//             width:  130, // was 100
//             height: 130, // was 100
//             child: Image.asset(
//               'assets/logoOphicina.png',
//               fit: BoxFit.contain,
//               errorBuilder: (_, __, ___) => _LogoFallback(
//                 size:        130,
//                 letter:      'O',
//                 letterColor: AppColors.greenCeladon,
//                 colors:      [AppColors.white, AppColors.greenCeladon],
//               ),
//             ),
//           ),

//           // ── Title slides up ──────────────────────────────────
//           FadeTransition(
//             opacity: _titleFade,
//             child: SlideTransition(
//               position: _titleSlide,
//               child: Text(
//                 'Ophicina',
//                 style: TextStyle(
//                   fontSize:      46,   // was 40 — larger, more commanding
//                   letterSpacing: 2.8,  // slightly wider tracking
//                   fontWeight:    FontWeight.w600,
//                   color:         AppColors.greenCeladon,
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 14), // was 12

//           // ── Tagline fades in ─────────────────────────────────
//           FadeTransition(
//             opacity: _taglineFade,
//             child: Text(
//               'Your opportunity is here',
//               style: TextStyle(
//                 fontSize:      16,   // was 15
//                 letterSpacing: 1.6,
//                 color:         AppColors.darkGreen,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  LOGO FALLBACK
// // ─────────────────────────────────────────────────────────────────
// class _LogoFallback extends StatelessWidget {
//   final double size;
//   final String letter;
//   final Color  letterColor;
//   final List<Color> colors;

//   const _LogoFallback({
//     required this.size,
//     required this.letter,
//     required this.letterColor,
//     required this.colors,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width:  size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: colors.first,
//       ),
//       child: Center(
//         child: Text(
//           letter,
//           style: TextStyle(
//             fontSize:   size * 0.60,
//             fontWeight: FontWeight.w700,
//             height:     1,
//             color:      letterColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  BLOB PAINTER
// // ─────────────────────────────────────────────────────────────────
// class _BlobPainter extends CustomPainter {
//   final Color  color;
//   final double morphProgress;

//   const _BlobPainter({required this.color, required this.morphProgress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final cx = size.width  / 2;
//     final cy = size.height / 2;
//     final r  = size.width  / 2;
//     final paint = Paint()..color = color..style = PaintingStyle.fill;

//     if (morphProgress < 0.01) {
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//     } else if (morphProgress > 0.99) {
//       canvas.drawCircle(Offset(cx, cy), r, paint);
//     } else {
//       canvas.drawPath(_organicPath(cx, cy, r), paint);
//       canvas.drawCircle(Offset(cx, cy), r * morphProgress, paint);
//     }
//   }

//   Path _organicPath(double cx, double cy, double r) {
//     return Path()
//       ..moveTo(cx - r * 0.10, cy - r * 0.85)
//       ..cubicTo(
//           cx - r * 0.55, cy - r * 1.05,
//           cx - r * 1.00, cy - r * 0.60,
//           cx - r * 0.95, cy - r * 0.10)
//       ..cubicTo(
//           cx - r * 0.90, cy + r * 0.30,
//           cx - r * 0.60, cy + r * 0.55,
//           cx,            cy + r * 0.70)
//       ..cubicTo(
//           cx + r * 0.60, cy + r * 0.55,
//           cx + r * 0.85, cy + r * 0.25,
//           cx + r * 0.95, cy - r * 0.05)
//       ..cubicTo(
//           cx + r * 1.05, cy - r * 0.50,
//           cx + r * 0.65, cy - r * 0.95,
//           cx + r * 0.20, cy - r * 0.90)
//       ..cubicTo(
//           cx,            cy - r * 0.85,
//           cx,            cy - r * 0.85,
//           cx - r * 0.10, cy - r * 0.85)
//       ..close();
//   }

//   @override
//   bool shouldRepaint(_BlobPainter old) =>
//       old.morphProgress != morphProgress || old.color != color;
// }

// // ─────────────────────────────────────────────────────────────────
// //  CORNER WIPE PAINTER
// // ─────────────────────────────────────────────────────────────────
// class _CornerWipePainter extends CustomPainter {
//   final double progress;
//   final Color  color;

//   const _CornerWipePainter({required this.progress, required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final maxRadius =
//         math.sqrt(size.width * size.width + size.height * size.height);
//     canvas.drawCircle(
//       Offset(size.width, size.height),
//       maxRadius * progress,
//       Paint()..color = color,
//     );
//   }

//   @override
//   bool shouldRepaint(_CornerWipePainter old) =>
//       old.progress != progress || old.color != color;
// }


import 'dart:math' as math;
import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/BlockedScreen.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/AdminEnum.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:provider/provider.dart';

import 'package:client/Widgets/LanguageSelector.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
// ... existing animation variables ...
  late AnimationController _blobCtrl;
  late Animation<double>   _blobScale;
  late Animation<double>   _blobMorph;

  late AnimationController _wipeCtrl;
  late Animation<double>   _wipeProgress;

  late AnimationController _titleCtrl;
  late Animation<double>   _titleFade;
  late Animation<Offset>   _titleSlide;

  late AnimationController _taglineCtrl;
  late Animation<double>   _taglineFade;

  bool _splashFinished = false;
  bool _navigated      = false;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runSequence();
  }

  void _initAnimations() {
    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _blobScale = CurvedAnimation(
      parent: _blobCtrl,
      curve: Curves.easeInOutCubic,
    );
    _blobMorph = CurvedAnimation(
      parent: _blobCtrl,
      curve: Curves.easeIn,
    );

    _wipeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _wipeProgress = CurvedAnimation(
      parent: _wipeCtrl,
      curve: Curves.easeInOutQuart,
    );

    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleFade  = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic),
    );

    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn);
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 900));
    await _blobCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _wipeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _titleCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _taglineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _splashFinished = true;
    _tryNavigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_tryNavigate);
  }

  void _tryNavigate() {
    if (!mounted || _navigated) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoading || !_splashFinished) return;
    _navigated = true;
    final user = auth.user;
    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else {
      _navigateBasedOnRole(user);
    }
  }

  Future<void> _navigateBasedOnRole(AppUser user) async {
    final recruiterRepo = RecruiterRepository();
    final jobSeekerRepo = JobSeekerRepository();

    switch (user.role) {
      case UserRole.admin:
        final profile = await AdminRepository().getByUid(user.userId);
        if (!mounted) return;
        if (profile == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AdminAccountScreen(mode: AdminFormMode.create),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
        }
        break;

      case UserRole.recruiter:
        if (user.isBlocked) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
          );
        } else {
          final profile = await recruiterRepo.getByUid(user.userId);
          if (!mounted) return;
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RecruiterAccountScreen(
                  mode: AccountFormMode.create,
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
          }
        }
        break;

      case UserRole.jobSeeker:
        if (user.isBlocked) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BlockedScreen(user: user)),
          );
        } else {
          final profile = await jobSeekerRepo.getByUid(user.userId);
          if (!mounted) return;
          if (profile == null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const JobSeekerAccountScreen(
                  mode: JobSeekerFormMode.create,
                ),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(
                context, AppRoutes.jobSeekerDash);
          }
        }
        break;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_tryNavigate);
    _blobCtrl.dispose();
    _wipeCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge(
                [_blobCtrl, _wipeCtrl, _titleCtrl, _taglineCtrl]),
            builder: (context, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildBlob(size),
                  _buildBlobContent(l10n),
                  if (_wipeCtrl.value > 0) _buildCornerWipe(size),
                  if (_titleCtrl.value > 0) _buildPostWipeContent(l10n),
                ],
              );
            },
          ),
          
          // Language Selector at top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: const LanguageSelector(),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Size size) {
    final maxDim =
        math.sqrt(size.width * size.width + size.height * size.height) * 1.05;
    const fraction = 0.82;
    final baseD       = size.width * fraction;
    final targetScale = maxDim / baseD;
    final scale       = 1.0 + _blobScale.value * (targetScale - 1.0);

    return Center(
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width:  baseD,
          height: baseD,
          child: CustomPaint(
            painter: _BlobPainter(
              color: AppColors.greenCeladon,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlobContent(AppLocalizations l10n) {
    final alpha = _wipeProgress.value < 0.40
        ? 1.0
        : 1.0 - ((_wipeProgress.value - 0.40) / 0.60).clamp(0.0, 1.0);

    return Opacity(
      opacity: alpha,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.app_title,
              style: TextStyle(
                fontSize:      36,
                letterSpacing: 4.0,
                fontWeight:    FontWeight.w800,
                color:         AppColors.white,
                height:        1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.tagline,
              style: TextStyle(
                fontSize:      19,
                letterSpacing: 2.8,
                fontWeight:    FontWeight.bold,
                color:         AppColors.white,
                height:        1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerWipe(Size size) {
    return CustomPaint(
      size: size,
      painter: _CornerWipePainter(
        progress: _wipeProgress.value,
        color:    AppColors.white,
      ),
    );
  }

  Widget _buildPostWipeContent(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width:  130,
            height: 130,
            child: Image.asset(
              'assets/logoOphicina.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _LogoFallback(
                size:        130,
                letter:      'O',
                letterColor: AppColors.greenCeladon,
                colors:      [AppColors.white, AppColors.greenCeladon],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                l10n.app_title,
                style: TextStyle(
                  fontSize:      42,
                  letterSpacing: 4.0,
                  fontWeight:    FontWeight.w800,
                  color:         AppColors.greenCeladon,
                  height:        1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _taglineFade,
            child: Text(
              l10n.tagline,
              style: TextStyle(
                fontSize:      19,
                letterSpacing: 2.8,
                fontWeight:    FontWeight.bold,
                color:         AppColors.green,
                height:        1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  LOGO FALLBACK
// ─────────────────────────────────────────────────────────────────
class _LogoFallback extends StatelessWidget {
  final double size;
  final String letter;
  final Color  letterColor;
  final List<Color> colors;

  const _LogoFallback({
    required this.size,
    required this.letter,
    required this.letterColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.first,
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize:   size * 0.60,
            fontWeight: FontWeight.w700,
            height:     1,
            color:      letterColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  BLOB PAINTER — plain circle, expands to fill screen
// ─────────────────────────────────────────────────────────────────
class _BlobPainter extends CustomPainter {
  final Color color;

  const _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────
//  CORNER WIPE PAINTER
// ─────────────────────────────────────────────────────────────────
class _CornerWipePainter extends CustomPainter {
  final double progress;
  final Color  color;

  const _CornerWipePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius =
        math.sqrt(size.width * size.width + size.height * size.height);
    canvas.drawCircle(
      Offset(size.width, size.height),
      maxRadius * progress,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CornerWipePainter old) =>
      old.progress != progress || old.color != color;
}