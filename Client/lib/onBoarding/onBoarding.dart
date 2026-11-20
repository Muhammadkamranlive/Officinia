
import 'package:client/Authentication/Login/login.dart';
import 'package:client/Authentication/Role/SelectRoleScreen.dart';
import 'package:client/Widgets/LanguageSelector.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';

import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;

  late Animation<double> _logoScale;
  late Animation<double> _fade;
  late Animation<Offset> _slideUp;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutExpo),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _glow = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _mainController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double maxWidth = size.width > 600 ? 480 : size.width;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── Background circle ──────────────────────────────
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: size.width,
              height: size.height / 1.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientgreen,
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────
          SafeArea(
            child: Center(
              child: SizedBox(
                width: maxWidth,
                height: size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ── Logo + Text section ──────────────────
                    Expanded(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slideUp,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: maxWidth * 0.07,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ── Animated logo ────────
                                  ScaleTransition(
                                    scale: _logoScale,
                                    child: AnimatedBuilder(
                                      animation: _glow,
                                      builder: (_, __) {
                                        final logoSize =
                                            (maxWidth * 0.55).clamp(120.0, 260.0);
                                        return Container(
                                          height: logoSize,
                                          width: logoSize,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.green
                                                    .withOpacity(_glow.value),
                                                blurRadius: 40,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Text(
                                              "O",
                                              style: TextStyle(
                                                fontSize: 100, // Fixed size for simplicity or keep responsive
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF69A88D),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // ── Title ────────────────
                                  Text(
                                    l10n.onboarding_title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          (maxWidth * 0.085).clamp(18.0, 36.0),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greenCeladon,
                                      letterSpacing: 0.4,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // ── Subtitle ─────────────
                                  Text(
                                    l10n.onboarding_subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          (maxWidth * 0.04).clamp(13.0, 18.0),
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Buttons section ──────────────────────
                    FadeTransition(
                      opacity: _fade,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: size.height * 0.055,
                          left: maxWidth * 0.06,
                          right: maxWidth * 0.06,
                          top: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _premiumButton(
                              text: l10n.sign_in,
                              size: Size(maxWidth, size.height),
                              gradient: AppColors.gradientgreen,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              ),
                            ),
                            _premiumButton(
                              text: l10n.sign_up,
                              size: Size(maxWidth, size.height),
                              gradient: AppColors.gradientdarkgreen,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectRoleScreen()),
                              ),
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

  Widget _premiumButton({
    required String text,
    required Size size,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: size.width * 0.4,
      height: size.height * 0.065,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: (size.width * 0.045).clamp(14.0, 20.0),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}