import 'package:client/AppColors/AppColors.dart';
import 'package:client/Recruiter/RecruiterDetailPage.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class MakeRecruitterPro extends StatefulWidget {
  final List<Recruiter> recruiters;

  const MakeRecruitterPro({super.key, required this.recruiters});

  @override
  State<MakeRecruitterPro> createState() => _MakeRecruitterProState();
}

class _MakeRecruitterProState extends State<MakeRecruitterPro> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRecruiters = widget.recruiters
        .where((r) =>
            r.isActive &&
            (r.profileStatus == "Normal" ||
            r.profileStatus == "" )&&
            (r.pharmacyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             r.pharmacistFirstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             r.city.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text(
          AppLocalizations.of(context)!.recruiterPromotionPanel,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LABEL
             Text(
              AppLocalizations.of(context)!.searchHintRecruiters,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            /// SEARCH FIELD
            TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchRecruiters,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SECTION LABEL
            Text(
              AppLocalizations.of(context)!.eligibleRecruiters,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: filteredRecruiters.isEmpty
                  ?  Center(
                      child: Text(
                        AppLocalizations.of(context)!.noRecruitersMatch,
                        style: TextStyle(fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredRecruiters.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final recruiter = filteredRecruiters[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecruiterDetailPage(recruiter: recruiter),
                              ),
                            );
                          },
                          child: _recruiterRow(
                            recruiter.pharmacyName,
                            recruiter.pharmacistFirstName,
                            recruiter.city,
                            recruiter.isActive,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _recruiterRow(
  String pharmacyName,
  String firstName,
  String city,
  bool isActive,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: AppColors.gradientdarkgreen,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        /// ICON CIRCLE
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isActive
                  ? [Colors.green.shade300, Colors.green.shade500]
                  : [Colors.grey.shade400, Colors.grey.shade600],
            ),
          ),
          child: Icon(
            isActive ? Icons.verified_user_rounded : Icons.pending,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),

        /// INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pharmacyName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                city,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),

        /// PREMIUM BADGE
        if (!isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context)!.premium,
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    ),
  );
}

}

