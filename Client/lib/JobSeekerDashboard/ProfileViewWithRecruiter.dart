// import 'package:client/AppColors/AppColors.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/Server/Model/JobSeekerModel/ProfileViewsStats.dart';
// import 'package:client/Server/Repo/ProfileViewsRepository.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProfileViewsScreen extends StatefulWidget {
//   const ProfileViewsScreen({super.key});

//   @override
//   State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
// }

// class _ProfileViewsScreenState extends State<ProfileViewsScreen> {
//   final repo = ProfileViewsRepository();
//   late Future<List<ProfileViewWithRecruiter>> _future;

//  @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     final userId = context.read<AuthProvider>().user!.userId;
//     _future = repo.getViewsWithRecruiters(userId);
//   }

//   Future<void> _refresh() async {
//     _loadData();
//     setState(() {}); // rebuild FutureBuilder with new future
//     await _future; // wait for future to complete
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: const Text("Profile Views", style: TextStyle( color: AppColors.darkGreen,fontWeight: FontWeight.w600,)),),
//       body: FutureBuilder<List<ProfileViewWithRecruiter>>(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const _EmptyViewsState();
//           }

//           final views = snapshot.data!;

//           return RefreshIndicator(
//            onRefresh: _refresh,
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(), // ensures pull works even if list is short
//               children: [
//                 _StatsSection(views: views),
//                 _ViewsChartSection(views: views),
//                 // const Padding(
//                 //   padding: EdgeInsets.all(16),
//                 //   child: Text(
//                 //     "Who viewed your profile",
//                 //     style: TextStyle(
//                 //       fontSize: 18,
//                 //       fontWeight: FontWeight.w800,
//                 //     ),
//                 //   ),
//                 // ),
//                 // ...views.map(
//                 //   (e) => RecruiterViewCard(item: e),
//                 // ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _StatsSection extends StatelessWidget {
//   final List<ProfileViewWithRecruiter> views;

//   const _StatsSection({required this.views});

//   @override
//   Widget build(BuildContext context) {
//     final totalViews = views.length;

//     final uniqueRecruiters =
//         views.map((e) => e.recruiter.userId).toSet().length;

//     final today = DateTime.now();
//     final todayViews = views.where((v) {
//       final d = v.view.createdAt;
//       return d.year == today.year &&
//           d.month == today.month &&
//           d.day == today.day;
//     }).length;

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           _StatCard(
//             title: "Total Views",
//             value: totalViews.toString(),
//             icon: Icons.remove_red_eye,
//             gradient: const [Color(0xff667eea), Color(0xff764ba2)],
//           ),
//           const SizedBox(width: 12),
//           _StatCard(
//             title: "Recruiters",
//             value: uniqueRecruiters.toString(),
//             icon: Icons.business,
//             gradient: const [Color(0xff11998e), Color(0xff38ef7d)],
//           ),
//           const SizedBox(width: 12),
//           _StatCard(
//             title: "Today",
//             value: todayViews.toString(),
//             icon: Icons.today,
//             gradient: const [Color(0xffff9966), Color(0xffff5e62)],
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final List<Color> gradient;

//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.gradient,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(22),
//           boxShadow: premiumShadow,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(height: 12),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w900,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RecruiterViewCard extends StatelessWidget {
//   final ProfileViewWithRecruiter item;

//   const RecruiterViewCard({super.key, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     final r = item.recruiter;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: premiumShadow,
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 26,
//             backgroundColor: AppColors.greenCeladon,
//             child: Text(
//               r.pharmacyName.isNotEmpty ? r.pharmacyName[0] : "?",
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
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
//                     fontWeight: FontWeight.w800,
//                     fontSize: 15,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   "${r.city}, ${r.province}",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.black54,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             _format(item.view.createdAt),
//             style: const TextStyle(
//               fontSize: 11,
//               color: Colors.black54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _format(DateTime d) =>
//       "${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
// }


// class _ViewsChartSection extends StatelessWidget {
//   final List<ProfileViewWithRecruiter> views;

//   const _ViewsChartSection({required this.views});

//   @override
//   Widget build(BuildContext context) {
//     final Map<int, int> dailyCount = {};

//     for (final v in views) {
//       final day = v.view.createdAt.day;
//       dailyCount[day] = (dailyCount[day] ?? 0) + 1;
//     }

//     return ProfileViewsChart(
//       dailyViews: buildLast7Days(views),
//     );
//   }
// }

// class ProfileViewsChart extends StatelessWidget {
//   final Map<DateTime, int> dailyViews;

//   const ProfileViewsChart({
//     super.key,
//     required this.dailyViews,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (dailyViews.isEmpty) {
//       return _EmptyChartCard();
//     }

//     final dates = dailyViews.keys.toList()..sort();
//     final values = dates.map((d) => dailyViews[d]!.toDouble()).toList();

//     final maxY = (values.reduce((a, b) => a > b ? a : b) + 1);

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(26),
//           boxShadow: premiumShadow,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// TITLE
//             const Text(
//               "Profile Views (Last 7 Days)",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 18),

//             /// CHART
//             SizedBox(
//               height: 220,
//               child: LineChart(
//                 LineChartData(
//                   minY: 0,
//                   maxY: maxY,

//                   /// GRID
//                   gridData: FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 1,
//                     getDrawingHorizontalLine: (value) => FlLine(
//                       color: Colors.black12,
//                       strokeWidth: 1,
//                       dashArray: [6, 6],
//                     ),
//                   ),

//                   /// AXES
//                   titlesData: FlTitlesData(
//                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

//                     /// LEFT (COUNTS)
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         interval: 1,
//                         reservedSize: 30,
//                         getTitlesWidget: (value, _) => Text(
//                           value.toInt().toString(),
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),

//                     /// BOTTOM (DATES)
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         interval: 1,
//                         getTitlesWidget: (value, _) {
//                           final index = value.toInt();
//                           if (index < 0 || index >= dates.length) {
//                             return const SizedBox.shrink();
//                           }
//                           final d = dates[index];
//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Text(
//                               "${d.day}/${d.month}",
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.black54,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   /// BORDER
//                   borderData: FlBorderData(show: false),

//                   /// LINE
//                   lineBarsData: [
//                     LineChartBarData(
//                       isCurved: true,
//                       barWidth: 4,
//                       color: AppColors.greenCeladon,
//                       isStrokeCapRound: true,

//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
//                           radius: 4,
//                           color: Colors.white,
//                           strokeWidth: 3,
//                           strokeColor: AppColors.greenCeladon,
//                         ),
//                       ),

//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.greenCeladon.withOpacity(.35),
//                             AppColors.greenCeladon.withOpacity(.05),
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),

//                       spots: List.generate(
//                         values.length,
//                         (i) => FlSpot(i.toDouble(), values[i]),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// Map<DateTime, int> buildLast7Days(List<ProfileViewWithRecruiter> views) {
//   final now = DateTime.now();
//   final Map<DateTime, int> map = {};

//   for (int i = 6; i >= 0; i--) {
//     final day = DateTime(now.year, now.month, now.day - i);
//     map[day] = 0;
//   }

//   for (final v in views) {
//     final d = v.view.createdAt;
//     final key = DateTime(d.year, d.month, d.day);
//     if (map.containsKey(key)) {
//       map[key] = map[key]! + 1;
//     }
//   }

//   return map;
// }

// class _EmptyChartCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Container(
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(26),
//           boxShadow: premiumShadow,
//         ),
//         child: const Center(
//           child: Text(
//             "No profile views trend yet",
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Colors.grey,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyViewsState extends StatelessWidget {
//   const _EmptyViewsState();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: const [
//           Icon(Icons.visibility_off, size: 60, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             "No profile views yet",
//             style: TextStyle(fontWeight: FontWeight.w700),
//           ),
//           SizedBox(height: 8),
//           Text(
//             "Recruiters will appear here when they view your profile",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.black54),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:client/AppColors/AppColors.dart';
// import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// import 'package:client/Server/Model/JobSeekerModel/ProfileViewsStats.dart';
// import 'package:client/Server/Repo/ProfileViewsRepository.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ProfileViewsScreen extends StatefulWidget {
//   const ProfileViewsScreen({super.key});

//   @override
//   State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
// }

// class _ProfileViewsScreenState extends State<ProfileViewsScreen>
//     with SingleTickerProviderStateMixin {
//   final repo = ProfileViewsRepository();
//   late Future<List<ProfileViewWithRecruiter>> _future;
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnim = CurvedAnimation(
//       parent: _animController,
//       curve: Curves.easeOut,
//     );
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   void _loadData() {
//     final userId = context.read<AuthProvider>().user!.userId;
//     _future = repo.getViewsWithRecruiters(userId);
//     _future.then((_) => _animController.forward(from: 0));
//   }

//   Future<void> _refresh() async {
//     _loadData();
//     setState(() {});
//     await _future;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         body: FutureBuilder<List<ProfileViewWithRecruiter>>(
//           future: _future,
//           builder: (context, snapshot) {
//             final loading =
//                 snapshot.connectionState == ConnectionState.waiting;
//             final empty = !loading &&
//                 (!snapshot.hasData || snapshot.data!.isEmpty);
//             final views = snapshot.data ?? [];
      
//             return CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 // ── Premium SliverAppBar ──────────────────────────
//                 SliverAppBar(
//                   expandedHeight: 70,
//                   pinned: true,
//                   stretch: true,
//                   backgroundColor: Colors.white,
//                   elevation: 0,
//                   flexibleSpace: FlexibleSpaceBar(
//                     stretchModes: const [StretchMode.fadeTitle],
//                     titlePadding: const EdgeInsets.only(
//                         left: 20, bottom: 16),
//                     title: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         ShaderMask(
//                           shaderCallback: (bounds) =>
//                               AppColors.gradientgreen.createShader(bounds),
//                           child: const Icon(
//                             Icons.bar_chart_rounded,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Profile Analytics',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w800,
//                             color: Colors.black87,
//                             letterSpacing: -0.3,
//                           ),
//                         ),
//                       ],
//                     ),
//                     background: Container(
//                       decoration: const BoxDecoration(color: Colors.white),
//                       child: Stack(
//                         children: [
//                           // Decorative gradient orb top-right
//                           Positioned(
//                             top: -30,
//                             right: -30,
//                             child: Container(
//                               width: 160,
//                               height: 160,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     AppColors.green.withOpacity(0.12),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             top: 20,
//                             right: 80,
//                             child: Container(
//                               width: 80,
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 gradient: RadialGradient(
//                                   colors: [
//                                     AppColors.greenCeladon.withOpacity(0.15),
//                                     Colors.transparent,
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   bottom: PreferredSize(
//                     preferredSize: const Size.fromHeight(1),
//                     child: Container(
//                       height: 1,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             AppColors.green.withOpacity(0.3),
//                             Colors.transparent,
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
      
//                 // ── Body ──────────────────────────────────────────
//                 if (loading)
//                   const SliverFillRemaining(
//                     child: Center(child: CircularProgressIndicator()),
//                   )
//                 else if (empty)
//                   const SliverFillRemaining(child: _EmptyViewsState())
//                 else
//                   SliverToBoxAdapter(
//                     child: RefreshIndicator(
//                       onRefresh: _refresh,
//                       color: AppColors.green,
//                       child: FadeTransition(
//                         opacity: _fadeAnim,
//                         child: Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // ── Stat cards ─────────────────────
//                               _StatsRow(views: views),
//                               const SizedBox(height: 24),
      
//                               // ── Section label ──────────────────
//                               _SectionLabel(
//                                 icon: Icons.show_chart_rounded,
//                                 label: 'Views Trend',
//                                 sub: 'Last 7 days',
//                               ),
//                               const SizedBox(height: 12),
      
//                               // ── Chart ──────────────────────────
//                               _PremiumChart(
//                                 dailyViews: buildLast7Days(views),
//                               ),
      
//                               const SizedBox(height: 24),
      
//                               // ── Weekly summary strip ───────────
//                               _WeeklySummaryStrip(views: views),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─── Section Label ────────────────────────────────────────────────────────────

// class _SectionLabel extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String sub;

//   const _SectionLabel({
//     required this.icon,
//     required this.label,
//     required this.sub,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             gradient: AppColors.gradientgreen,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: Colors.white, size: 18),
//         ),
//         const SizedBox(width: 10),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15,
//                   color: Colors.black87,
//                 )),
//             Text(sub,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey.shade500,
//                   fontWeight: FontWeight.w500,
//                 )),
//           ],
//         ),
//       ],
//     );
//   }
// }

// // ─── Stats Row ────────────────────────────────────────────────────────────────

// class _StatsRow extends StatelessWidget {
//   final List<ProfileViewWithRecruiter> views;
//   const _StatsRow({required this.views});

//   @override
//   Widget build(BuildContext context) {
//     final totalViews = views.length;
//     final uniqueRecruiters =
//         views.map((e) => e.recruiter.userId).toSet().length;
//     final today = DateTime.now();
//     final todayViews = views.where((v) {
//       final d = v.view.createdAt;
//       return d.year == today.year &&
//           d.month == today.month &&
//           d.day == today.day;
//     }).length;

//     // Week views
//     final weekStart = today.subtract(const Duration(days: 7));
//     final weekViews = views
//         .where((v) => v.view.createdAt.isAfter(weekStart))
//         .length;

//     return Column(
//       children: [
//         // Top row — big hero card
//         _HeroStatCard(
//           value: totalViews.toString(),
//           label: 'Total Profile Views',
//           sublabel: '+$weekViews this week',
//           icon: Icons.remove_red_eye_rounded,
//           gradient: AppColors.gradientgreen,
//         ),
//         const SizedBox(height: 12),
//         // Bottom row — two smaller cards
//         Row(
//           children: [
//             Expanded(
//               child: _MiniStatCard(
//                 value: uniqueRecruiters.toString(),
//                 label: 'Recruiters',
//                 icon: Icons.business_rounded,
//                 color: const Color(0xff6C63FF),
//                 bgColor: const Color(0xffF0EEFF),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _MiniStatCard(
//                 value: todayViews.toString(),
//                 label: 'Today',
//                 icon: Icons.today_rounded,
//                 color: const Color(0xffFF6B6B),
//                 bgColor: const Color(0xffFFF0F0),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _HeroStatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final String sublabel;
//   final IconData icon;
//   final Gradient gradient;

//   const _HeroStatCard({
//     required this.value,
//     required this.label,
//     required this.sublabel,
//     required this.icon,
//     required this.gradient,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: gradient,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.green.withOpacity(0.35),
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // Decorative circle
//           Positioned(
//             right: -20,
//             top: -20,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             right: 20,
//             bottom: -10,
//             child: Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 26),
//               ),
//               const SizedBox(width: 16),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 38,
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                       height: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       sublabel,
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MiniStatCard extends StatelessWidget {
//   final String value;
//   final String label;
//   final IconData icon;
//   final Color color;
//   final Color bgColor;

//   const _MiniStatCard({
//     required this.value,
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.bgColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.w900,
//                   color: color,
//                   height: 1,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade500,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─── Weekly Summary Strip ─────────────────────────────────────────────────────

// class _WeeklySummaryStrip extends StatelessWidget {
//   final List<ProfileViewWithRecruiter> views;
//   const _WeeklySummaryStrip({required this.views});

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final days = List.generate(7, (i) {
//       final d = DateTime(now.year, now.month, now.day - (6 - i));
//       final count = views.where((v) {
//         final vd = v.view.createdAt;
//         return vd.year == d.year &&
//             vd.month == d.month &&
//             vd.day == d.day;
//       }).length;
//       return _DayCount(date: d, count: count);
//     });

//     final maxCount = days.map((d) => d.count).reduce((a, b) => a > b ? a : b);
//     final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.gradientgreen,
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//                 child: const Icon(Icons.calendar_today_rounded,
//                     color: Colors.white, size: 15),
//               ),
//               const SizedBox(width: 10),
//               const Text(
//                 'Daily Breakdown',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 18),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: days.asMap().entries.map((entry) {
//               final i = entry.key;
//               final d = entry.value;
//               final isToday = d.date.day == now.day &&
//                   d.date.month == now.month;
//               final heightFraction =
//                   maxCount == 0 ? 0.0 : d.count / maxCount;
//               final barHeight = 4.0 + heightFraction * 44;

//               return Column(
//                 children: [
//                   // Count badge
//                   if (d.count > 0)
//                     Container(
//                       margin: const EdgeInsets.only(bottom: 4),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 5, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: isToday
//                             ? AppColors.green
//                             : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         '${d.count}',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: isToday
//                               ? Colors.white
//                               : Colors.grey.shade600,
//                         ),
//                       ),
//                     )
//                   else
//                     const SizedBox(height: 22),

//                   // Bar
//                   AnimatedContainer(
//                     duration:
//                         Duration(milliseconds: 400 + i * 60),
//                     curve: Curves.easeOut,
//                     width: 28,
//                     height: barHeight,
//                     decoration: BoxDecoration(
//                       gradient: isToday
//                           ? AppColors.gradientgreen
//                           : LinearGradient(
//                               colors: [
//                                 Colors.grey.shade300,
//                                 Colors.grey.shade200,
//                               ],
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                             ),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   const SizedBox(height: 6),

//                   // Day label
//                   Text(
//                     isToday
//                         ? 'Today'
//                         : dayNames[d.date.weekday - 1],
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: isToday
//                           ? FontWeight.w700
//                           : FontWeight.w500,
//                       color: isToday
//                           ? AppColors.green
//                           : Colors.grey.shade400,
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DayCount {
//   final DateTime date;
//   final int count;
//   const _DayCount({required this.date, required this.count});
// }

// // ─── Premium Chart ────────────────────────────────────────────────────────────

// class _PremiumChart extends StatelessWidget {
//   final Map<DateTime, int> dailyViews;
//   const _PremiumChart({required this.dailyViews});

//   @override
//   Widget build(BuildContext context) {
//     if (dailyViews.isEmpty) {
//       return _EmptyChartCard();
//     }

//     final dates = dailyViews.keys.toList()..sort();
//     final values =
//         dates.map((d) => dailyViews[d]!.toDouble()).toList();
//     final maxY =
//         (values.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 200,
//         child: LineChart(
//           LineChartData(
//             minY: 0,
//             maxY: maxY,
//             clipData: FlClipData.all(),
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: false,
//               horizontalInterval: 1,
//               getDrawingHorizontalLine: (_) => FlLine(
//                 color: Colors.grey.shade100,
//                 strokeWidth: 1.5,
//               ),
//             ),
//             titlesData: FlTitlesData(
//               rightTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false)),
//               topTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false)),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   interval: 1,
//                   reservedSize: 28,
//                   getTitlesWidget: (value, _) => Text(
//                     value.toInt().toString(),
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey.shade400,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   interval: 1,
//                   getTitlesWidget: (value, _) {
//                     final index = value.toInt();
//                     if (index < 0 || index >= dates.length) {
//                       return const SizedBox.shrink();
//                     }
//                     final d = dates[index];
//                     final isToday = d.day == DateTime.now().day &&
//                         d.month == DateTime.now().month;
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 8),
//                       child: Text(
//                         "${d.day}/${d.month}",
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: isToday
//                               ? AppColors.green
//                               : Colors.grey.shade400,
//                           fontWeight: isToday
//                               ? FontWeight.w800
//                               : FontWeight.w600,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             borderData: FlBorderData(show: false),
//             lineTouchData: LineTouchData(
//               touchTooltipData: LineTouchTooltipData(
//                 tooltipBgColor: AppColors.green,
//                 tooltipRoundedRadius: 10,
//                 getTooltipItems: (spots) => spots
//                     .map((s) => LineTooltipItem(
//                           '${s.y.toInt()} views',
//                           const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 12,
//                           ),
//                         ))
//                     .toList(),
//               ),
//             ),
//             lineBarsData: [
//               LineChartBarData(
//                 isCurved: true,
//                 curveSmoothness: 0.35,
//                 barWidth: 3,
//                 color: AppColors.green,
//                 isStrokeCapRound: true,
//                 dotData: FlDotData(
//                   show: true,
//                   getDotPainter: (spot, _, __, ___) {
//                     final isToday = dates[spot.x.toInt()].day ==
//                         DateTime.now().day;
//                     return FlDotCirclePainter(
//                       radius: isToday ? 5 : 3,
//                       color: Colors.white,
//                       strokeWidth: isToday ? 3 : 2,
//                       strokeColor: AppColors.green,
//                     );
//                   },
//                 ),
//                 belowBarData: BarAreaData(
//                   show: true,
//                   gradient: LinearGradient(
//                     colors: [
//                       AppColors.green.withOpacity(0.2),
//                       AppColors.green.withOpacity(0.0),
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 spots: List.generate(
//                   values.length,
//                   (i) => FlSpot(i.toDouble(), values[i]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─── Helpers ──────────────────────────────────────────────────────────────────

// Map<DateTime, int> buildLast7Days(
//     List<ProfileViewWithRecruiter> views) {
//   final now = DateTime.now();
//   final Map<DateTime, int> map = {};
//   for (int i = 6; i >= 0; i--) {
//     final day = DateTime(now.year, now.month, now.day - i);
//     map[day] = 0;
//   }
//   for (final v in views) {
//     final d = v.view.createdAt;
//     final key = DateTime(d.year, d.month, d.day);
//     if (map.containsKey(key)) map[key] = map[key]! + 1;
//   }
//   return map;
// }

// class _EmptyChartCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.show_chart_rounded,
//                 size: 36, color: Colors.grey.shade300),
//             const SizedBox(height: 8),
//             Text(
//               'No trend data yet',
//               style: TextStyle(
//                 color: Colors.grey.shade400,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EmptyViewsState extends StatelessWidget {
//   const _EmptyViewsState();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 90,
//               height: 90,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.visibility_off_rounded,
//                   size: 42, color: Colors.grey.shade300),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               "No profile views yet",
//               style: TextStyle(
//                 fontWeight: FontWeight.w800,
//                 fontSize: 17,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "When recruiters view your profile,\nyour analytics will appear here.",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/JobSeekerModel/ProfileViewsStats.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class ProfileViewsScreen extends StatefulWidget {
  const ProfileViewsScreen({super.key});

  @override
  State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
}

class _ProfileViewsScreenState extends State<ProfileViewsScreen>
    with SingleTickerProviderStateMixin {
  final repo = ProfileViewsRepository();
  late Future<List<ProfileViewWithRecruiter>> _future;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadData() {
    final userId = context.read<AuthProvider>().user!.userId;
    _future = repo.getViewsWithRecruiters(userId);
    _future.then((_) => _animController.forward(from: 0));
  }

  Future<void> _refresh() async {
    _loadData();
    setState(() {});
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SafeArea must NOT wrap Scaffold — it clips the SliverAppBar's status bar
    // area. Scaffold itself handles window insets. SliverAppBar with pinned:true
    // correctly respects the top MediaQuery padding on its own.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<ProfileViewWithRecruiter>>(
        future: _future,
        builder: (context, snapshot) {
          final loading =
              snapshot.connectionState == ConnectionState.waiting;
          final empty =
              !loading && (!snapshot.hasData || snapshot.data!.isEmpty);
          final views = snapshot.data ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Premium SliverAppBar ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.fadeTitle],
                  titlePadding:
                      const EdgeInsets.only(left: 20, bottom: 16),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.gradientgreen.createShader(bounds),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.profile_analytics_title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppColors.green.withOpacity(0.12),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 80,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                AppColors.greenCeladon.withOpacity(0.15),
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.green.withOpacity(0.3),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (empty)
                const SliverFillRemaining(child: _EmptyViewsState())
              else
                SliverToBoxAdapter(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.green,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 20, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatsRow(views: views),
                            const SizedBox(height: 24),
                            _SectionLabel(
                              icon: Icons.show_chart_rounded,
                              label: AppLocalizations.of(context)!.views_trend_title,
                              sub: AppLocalizations.of(context)!.last_7_days_subtitle,
                            ),
                            const SizedBox(height: 12),
                            _PremiumChart(
                                dailyViews: buildLast7Days(views)),
                            const SizedBox(height: 24),
                            _WeeklySummaryStrip(views: views),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _SectionLabel(
      {required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.gradientgreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.black87)),
            Text(sub,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<ProfileViewWithRecruiter> views;
  const _StatsRow({required this.views});

  @override
  Widget build(BuildContext context) {
    final totalViews = views.length;
    final uniqueRecruiters =
        views.map((e) => e.recruiter.userId).toSet().length;
    final today = DateTime.now();
    final todayViews = views.where((v) {
      final d = v.view.createdAt;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).length;
    final weekStart = today.subtract(const Duration(days: 7));
    final weekViews =
        views.where((v) => v.view.createdAt.isAfter(weekStart)).length;

    return Column(
      children: [
        _HeroStatCard(
          value: totalViews.toString(),
          label: AppLocalizations.of(context)!.total_profile_views,
          sublabel: AppLocalizations.of(context)!.this_week_views(weekViews),
          icon: Icons.remove_red_eye_rounded,
          gradient: AppColors.gradientgreen,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                value: uniqueRecruiters.toString(),
                label: AppLocalizations.of(context)!.recruiters_label,
                icon: Icons.business_rounded,
                accentColor: const Color(0xff6C63FF),
                lightColor: const Color(0xffF0EEFF),
                gradientColors: const [
                  Color(0xff6C63FF),
                  Color(0xff9B8FFF)
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniStatCard(
                value: todayViews.toString(),
                label: AppLocalizations.of(context)!.todays_views_label,
                icon: Icons.today_rounded,
                accentColor: const Color(0xffFF6B6B),
                lightColor: const Color(0xffFFF0F0),
                gradientColors: const [
                  Color(0xffFF6B6B),
                  Color(0xffFF9999)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Hero Stat Card ───────────────────────────────────────────────────────────

class _HeroStatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final IconData icon;
  final Gradient gradient;

  const _HeroStatCard({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1)),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(sublabel,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat Card — gradient icon + colored number + accent bar ─────────────

class _MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color lightColor;
  final List<Color> gradientColors;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.lightColor,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ✅ Colored shadow matching the card's theme
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        // ✅ Subtle colored border
        border: Border.all(
          color: accentColor.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Gradient icon container
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),

          const SizedBox(height: 14),

          // ✅ Number with gradient shader
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white, // color painted over by ShaderMask
                height: 1,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // ✅ Gradient accent bar at bottom
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                ...gradientColors,
                gradientColors.last.withOpacity(0),
              ]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weekly Summary Strip ─────────────────────────────────────────────────────

class _WeeklySummaryStrip extends StatelessWidget {
  final List<ProfileViewWithRecruiter> views;
  const _WeeklySummaryStrip({required this.views});

  String getDayName(BuildContext context, int weekday) {
    switch (weekday) {
      case 1: return AppLocalizations.of(context)!.day_mon;
      case 2: return AppLocalizations.of(context)!.day_tue;
      case 3: return AppLocalizations.of(context)!.day_wed;
      case 4: return AppLocalizations.of(context)!.day_thu;
      case 5: return AppLocalizations.of(context)!.day_fri;
      case 6: return AppLocalizations.of(context)!.day_sat;
      case 7: return AppLocalizations.of(context)!.day_sun;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day - (6 - i));
      final count = views.where((v) {
        final vd = v.view.createdAt;
        return vd.year == d.year &&
            vd.month == d.month &&
            vd.day == d.day;
      }).length;
      return _DayCount(date: d, count: count);
    });

    final maxCount =
        days.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientgreen,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context)!.daily_breakdown_title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final isToday =
                  d.date.day == now.day && d.date.month == now.month;
              final heightFraction =
                  maxCount == 0 ? 0.0 : d.count / maxCount;
              final barHeight = 4.0 + heightFraction * 44;

              return Column(
                children: [
                  if (d.count > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.green
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${d.count}',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isToday
                                  ? Colors.white
                                  : Colors.grey.shade600)),
                    )
                  else
                    const SizedBox(height: 22),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 60),
                    curve: Curves.easeOut,
                    width: 28,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: isToday
                          ? AppColors.gradientgreen
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isToday ? AppLocalizations.of(context)!.today_label : getDayName(context, d.date.weekday),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isToday
                          ? AppColors.green
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCount {
  final DateTime date;
  final int count;
  const _DayCount({required this.date, required this.count});
}

// ─── Premium Chart ────────────────────────────────────────────────────────────

class _PremiumChart extends StatelessWidget {
  final Map<DateTime, int> dailyViews;
  const _PremiumChart({required this.dailyViews});

  @override
  Widget build(BuildContext context) {
    if (dailyViews.isEmpty) return _EmptyChartCard();

    final dates = dailyViews.keys.toList()..sort();
    final values = dates.map((d) => dailyViews[d]!.toDouble()).toList();
    final maxY =
        (values.reduce((a, b) => a > b ? a : b) + 1).ceilToDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            clipData: FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.shade100, strokeWidth: 1.5),
            ),
            titlesData: FlTitlesData(
              rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= dates.length)
                      return const SizedBox.shrink();
                    final d = dates[index];
                    final isToday = d.day == DateTime.now().day &&
                        d.month == DateTime.now().month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("${d.day}/${d.month}",
                          style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.green
                                  : Colors.grey.shade400,
                              fontWeight: isToday
                                  ? FontWeight.w800
                                  : FontWeight.w600)),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.green,
                tooltipRoundedRadius: 10,
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(
                        AppLocalizations.of(context)!.views_count_tooltip(s.y.toInt()),
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)))
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                curveSmoothness: 0.35,
                barWidth: 3,
                color: AppColors.green,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) {
                    final isToday = dates[spot.x.toInt()].day ==
                        DateTime.now().day;
                    return FlDotCirclePainter(
                      radius: isToday ? 5 : 3,
                      color: Colors.white,
                      strokeWidth: isToday ? 3 : 2,
                      strokeColor: AppColors.green,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.green.withOpacity(0.2),
                      AppColors.green.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                spots: List.generate(values.length,
                    (i) => FlSpot(i.toDouble(), values[i])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Map<DateTime, int> buildLast7Days(List<ProfileViewWithRecruiter> views) {
  final now = DateTime.now();
  final Map<DateTime, int> map = {};
  for (int i = 6; i >= 0; i--) {
    map[DateTime(now.year, now.month, now.day - i)] = 0;
  }
  for (final v in views) {
    final d = v.view.createdAt;
    final key = DateTime(d.year, d.month, d.day);
    if (map.containsKey(key)) map[key] = map[key]! + 1;
  }
  return map;
}

class _EmptyChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.no_trend_data,
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _EmptyViewsState extends StatelessWidget {
  const _EmptyViewsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.visibility_off_rounded,
                  size: 42, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.no_profile_views_title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.no_profile_views_subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}