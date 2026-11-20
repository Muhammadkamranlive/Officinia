// ignore: file_names
import 'package:client/AppColors/AppColors.dart';
import 'package:client/JobSeekerDashboard/JobApplicationTrackingScreen.dart';
import 'package:client/JobSeekerDashboard/JobSeekerDash.dart';
import 'package:client/JobSeekerDashboard/JoblistsForJobSeekers/JobListScreen.dart';
import 'package:client/JobSeekerDashboard/ProfileViewWithRecruiter.dart';
import 'package:client/Recruiter/Chat/ChatListScreen.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class MainShellJobSeeker extends StatefulWidget {
  const MainShellJobSeeker({super.key});

  @override
  State<MainShellJobSeeker> createState() => _MainShellJobSeekerState();
}

class _MainShellJobSeekerState extends State<MainShellJobSeeker>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // 🔑 Navigator keys (one per tab)
  final _homeKey               = GlobalKey<NavigatorState>();
  final _jobsKey               = GlobalKey<NavigatorState>();
  final _jobsApplicationKey    = GlobalKey<NavigatorState>();
  final _chatKey               = GlobalKey<NavigatorState>();
  // ignore: non_constant_identifier_names
  final _ProfileKey = GlobalKey<NavigatorState>();

  late AnimationController _controller;

  final Gradient _gradientGreen = AppColors.gradientgreen;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔹 Navigator wrapper for each tab
  Widget _tabNavigator(GlobalKey<NavigatorState> key, Widget screen) {
    return Navigator(
      key: key,
      onGenerateRoute: (_) {
        return MaterialPageRoute(builder: (_) => screen);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screens = [
      _tabNavigator(_homeKey, const JobSeekDashboardScreen()),
      _tabNavigator(_jobsKey, const JobSeekerHomeScreen()),
      _tabNavigator(_jobsApplicationKey,  JobApplicationTrackingScreen()),
      _tabNavigator(_chatKey,  ChatListScreen()),
      _tabNavigator(_ProfileKey, const ProfileViewsScreen()),
    ];

    return WillPopScope(
      onWillPop: () async {
        final currentNavigator = [
          _homeKey,
          _jobsKey,
          _jobsApplicationKey,
          _chatKey,
          _ProfileKey,
        ][_currentIndex];

        if (currentNavigator.currentState?.canPop() ?? false) {
          currentNavigator.currentState!.pop();
          return false;
        }
        return true; // exit app
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: screens),
        /// 🔹 Bottom Navigation
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // evenly distributes space
              children: [
                _navItem(Icons.home, 0, l10n.nav_home),
                _navItem(Icons.campaign, 1, l10n.nav_jobs),
                _navItem(Icons.work_outline, 2, l10n.nav_applications),
                _navItem(Icons.messenger, 3, l10n.nav_messages),
                _navItem(Icons.insights_outlined, 4, l10n.nav_insights),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Bottom Nav Item
  Widget _navItem(IconData icon, int index, String label) {
    final selected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) {
          // Pop to root of current tab
          final navigator = [
            _homeKey,
            _jobsKey,
            _jobsApplicationKey,
            _chatKey,
            _ProfileKey,
          ][index];

          navigator.currentState?.popUntil((r) => r.isFirst);
          
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          selected
              ? AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return _gradientGreen.createShader(
                          Rect.fromLTWH(
                            -bounds.width +
                                (bounds.width * 2) * _controller.value,
                            0,
                            bounds.width,
                            bounds.height,
                          ),
                        );
                      },
                      child: Icon(icon, color: Colors.white),
                    );
                  },
                )
              : Icon(icon, color: AppColors.textDark),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? AppColors.green : AppColors.textDark,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
