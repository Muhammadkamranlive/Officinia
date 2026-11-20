import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/AdminAddUserScreen.dart';
import 'package:client/AdminPannel/AdminAppealsScreen.dart';
import 'package:client/AdminPannel/AdminPaymentsScreen.dart';
import 'package:client/AdminPannel/MyReportedIssuesScreen.dart';
import 'package:client/AdminPannel/ReportIssueScreen.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobOptions/ManageExperienceLevelsScreen.dart';
import 'package:client/JobOptions/ManageJobOptionsScreen.dart';
import 'package:client/JobOptions/ManageJobTypesScreen.dart';
import 'package:client/JobOptions/ManageLocationsScreen.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/JobSeekerDashboard/ProfileViewWithRecruiter.dart';
import 'package:client/Payment/PaymentConfigScreen.dart';
import 'package:client/Profile/DeleteAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/AdminEnum.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/routes/app_routes.dart';
import 'package:client/Widgets/LanguageSelector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';

class JobSeekerDrawer extends StatelessWidget {
  final JobSeekerModel recruiterUser;
  const JobSeekerDrawer({super.key, required this.recruiterUser});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientgreen1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child:
                          recruiterUser.logoUrl != null &&
                              recruiterUser.logoUrl!.isNotEmpty
                          ? Image.network(
                              recruiterUser.logoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    l10n.my_profile,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: l10n.edit_profile,
                      subtitle: l10n.personal_pro_info,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JobSeekerAccountScreen(
                              mode: JobSeekerFormMode.edit,
                            ),
                          ),
                        );
                      },
                    ),
                    

                    _drawerItem(
                      context,
                      icon: Icons.stacked_line_chart_outlined,
                      title: l10n.profile_views_drawer,
                      subtitle: l10n.profile_views_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileViewsScreen(),
                          ),
                        );
                      },
                    ),
                    // ⚙️ MANAGE ACCOUNT (CARD STYLE)
                    _drawerItem(
                      context,
                      icon: Icons.bug_report_outlined,
                      title: l10n.report_issue,
                      subtitle: l10n.report_issue_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportIssueScreen(
                              mode: ReportIssueMode.create,
                            ),
                          ),
                        );
                      },
                    ),
                    // ⚙️ MANAGE ACCOUNT (CARD STYLE)
                    _drawerItem(
                      context,
                      icon: Icons.report_problem_outlined,
                      title: l10n.reported_issues,
                      subtitle: l10n.reported_issues_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyReportedIssuesScreen(
                              isAdminView: false,
                            ),
                          ),
                        );
                      },
                    ),

                    _drawerItem(
                      context,
                      icon: Icons.logout,
                      title: l10n.logout,
                      subtitle: l10n.logout_desc,
                      
                      onTap: () async {
                        await context.read<AuthProvider>().logout();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                     _drawerItem(
                      context,
                      icon: Icons.delete_forever,
                      isDestructive: true,
                      title: l10n.delete_account,
                      subtitle: l10n.delete_account_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(
                             
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: AppColors.darkGreen, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.language,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const SizedBox(
                            width: 82,
                            height: 38,
                            child: LanguageSelector(isDashboard: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        "© 2026 Ophicina",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.darkGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
}

class RecruiterDrawer extends StatelessWidget {
  const RecruiterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientgreen1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _drawerItem(
              context,
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Personal & professional info",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecruiterAccountScreen(
                      mode: AccountFormMode.edit,
                    ),
                  ),
                );
              },
            ),

            _drawerItem(
              context,
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out",
              isDestructive: true,
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "© 2026 Ophicina",
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.darkGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
}

class AdminDrawer extends StatelessWidget {
  final AdminsModel admin;
  // ignore: non_constant_identifier_names
  const AdminDrawer({super.key,required this.admin});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientgreen1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child:
                          admin.logoUrl != null &&
                              admin.logoUrl!.isNotEmpty
                          ? Image.network(
                              admin.logoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.person, size: 50);
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    admin.pharmacyName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${admin.pharmacistFirstName} ${admin.pharmacistLastName}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: l10n.edit_profile,
                      subtitle: l10n.personal_pro_info,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAccountScreen(
                              mode: AdminFormMode.edit,
                            ),
                          ),
                        );
                      },
                    ),
                      _drawerItem(
                      context,
                      icon: Icons.payment_outlined,
                      title: l10n.admin_drawer_payments_title,
                      subtitle: l10n.admin_drawer_payments_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminPaymentsScreen(
                              
                            ),
                          ),
                        );
                      },
                    ),
                    // _drawerItem(
                    //   context,
                    //   icon: Icons.admin_panel_settings_outlined,
                    //   title: "Add new Admin",
                    //   subtitle: "Manage admin accounts",
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (_) => const AdminAddUserScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    _drawerItem(
                      context,
                      icon: Icons.work_outline,
                      title: l10n.admin_drawer_job_options_title,
                      subtitle: l10n.admin_drawer_job_options_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageJobOptionsScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.category_outlined,
                      title: l10n.admin_drawer_job_types_title,
                      subtitle: l10n.admin_drawer_job_types_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageJobTypesScreen(),
                          ),
                        );
                      },
                    ),
                     _drawerItem(
                      context,
                      icon: Icons.bar_chart_outlined,
                      title: l10n.admin_drawer_exp_levels_title,
                      subtitle: l10n.admin_drawer_exp_levels_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageExperienceLevelsScreen(),
                          ),
                        );
                      },
                    ),
                     _drawerItem(
                      context,
                      icon: Icons.location_on_outlined,
                      title: l10n.admin_drawer_locations_title,
                      subtitle: l10n.admin_drawer_locations_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManageLocationsScreen(),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: l10n.admin_drawer_payment_config_title,
                      subtitle: l10n.admin_drawer_payment_config_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentConfigScreen(
                            ),
                          ),
                        );
                      },
                    ),
                    _drawerItem(
                      context,
                      icon: Icons.person_outline,
                      title: l10n.delete_account,
                      subtitle: l10n.delete_account_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(
                            ),
                          ),
                        );
                      },
                    ),
                   

                    _drawerItem(
                      context,
                      icon: Icons.app_registration,
                      title: l10n.admin_drawer_appeals_title,
                      subtitle: l10n.admin_drawer_appeals_sub,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminAppealsScreen(),
                          ),
                        );
                      },
                    ),
                    
                    _drawerItem(
                      context,
                      icon: Icons.bug_report_outlined,
                      title: l10n.report_issue,
                      subtitle: l10n.report_issue_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportIssueScreen(
                              mode: ReportIssueMode.create,
                            ),
                          ),
                        );
                      },
                    ),
                   
                    _drawerItem(
                      context,
                      icon: Icons.report_problem_outlined,
                      title: l10n.reported_issues,
                      subtitle: l10n.reported_issues_desc,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyReportedIssuesScreen(
                              isAdminView: true,
                            ),
                          ),
                        );
                      },
                    ),

                    _drawerItem(
                      context,
                      icon: Icons.logout,
                      title: l10n.logout,
                      subtitle: l10n.logout_desc,
                      isDestructive: true,
                      onTap: () async{
                        await context.read<AuthProvider>().logout();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                    ),
                    const Divider(indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: AppColors.darkGreen, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.language,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const SizedBox(
                            width: 82,
                            height: 38,
                            child: LanguageSelector(isDashboard: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        "© 2026 Ophicina",
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.darkGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
}
