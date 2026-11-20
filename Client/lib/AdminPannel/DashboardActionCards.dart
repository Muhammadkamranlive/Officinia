import 'package:client/AdminPannel/AdminPaymentsScreen.dart';
import 'package:client/AdminPannel/MakeRecruiterPro.dart';
import 'package:client/AdminPannel/RecruiterVerifucations.dart';
import 'package:client/Server/Model/PaymentStatus.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/AdminPannel/PaymentsScreen.dart';

import '../l10n/app_localizations.dart';

class DashboardActionCards extends StatelessWidget {
  final List<Recruiter>      recruiterRequestsCount;
  final List<PaymentEntry>   paymentsCount;

  const DashboardActionCards({
    super.key,
    required this.recruiterRequestsCount,
    required this.paymentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveRecruiters = recruiterRequestsCount.where((r) => r.isActive && (r.profileStatus=="Normal"|| r.profileStatus=="")).toList();
    final unverfiedRecruiters= recruiterRequestsCount.where((r)=> !r.isActive).toList();
    return Column(
      children: [
        /// RECRUITER VERIFICATION REQUEST CARD
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RecruiterVerificationScreen(recruiters: recruiterRequestsCount)),
            );
          },
          child: Container(
            width: double.infinity, // ✅ Full width
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.admin_verification_title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.pending_count_label(unverfiedRecruiters.length),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
          /// RECRUITER VERIFICATION REQUEST CARD
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MakeRecruitterPro(recruiters: recruiterRequestsCount)),
            );
          },
          child: Container(
            width: double.infinity, // ✅ Full width
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientGoldenLuxury,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond_outlined,
                    size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.make_featured_card,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.pending_count_label(inactiveRecruiters.length),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),

        /// PAYMENTS CARD
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AdminPaymentsScreen(),
              ),
            );
          },
          child: Container(
            width: double.infinity, // ✅ Full width
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: AppColors.gradientgreen1,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.payment, size: 28, color: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      AppLocalizations.of(context)!.admin_payments_title,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.transactions_count_label(paymentsCount.length),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
