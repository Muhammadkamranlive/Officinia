import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Guard/AuthProvider/RoleSelectionProvider.dart';
import '../../l10n/app_localizations.dart';
import '../../routes/app_routes.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
       backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          
          SizedBox(
            height: size.height,
            child: Center(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const SizedBox(height: 40,),
                      /// LOGO
                      Text(
                        l10n.app_title,
                        style: TextStyle(
                          fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenCeladon,
                        ),
                      ),
              
                      const SizedBox(height: 8),
              
                      /// TAGLINE
                      Text(
                        l10n.tagline,
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                     const SizedBox(
                      height: 40,
                     ),
                      /// JOB SEEKER BUTTON
                      _roleButton(
                        size: size,
                        text: l10n.role_job_seeker,
                        onTap: () {
                          context
                              .read<RoleSelectionProvider>()
                              .selectRole(UserRole.jobSeeker);
              
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                      ),
              
                      SizedBox(height: size.height * 0.025),
              
                      /// RECRUITER BUTTON
                      _roleButton(
                        size: size,
                        text: l10n.role_recruiter,
                        isOutlined: true,
                        onTap: () {
                          context
                              .read<RoleSelectionProvider>()
                              .selectRole(UserRole.recruiter);
              
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                      ),
              
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton({
    required Size size,
    required String text,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.075,
      child: Container(
        decoration: BoxDecoration(
          gradient: isOutlined ? null : AppColors.gradientgreen,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined
              ? Border.all(color: AppColors.greenCeladon, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
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
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: isOutlined ? AppColors.greenCeladon : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
