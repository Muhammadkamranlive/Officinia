import 'package:client/Recruiter/RecruiterDetailPage.dart';
import 'package:client/Server/Model/Recruiter.dart';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
class RecruiterVerificationScreen extends StatefulWidget {
  final List<Recruiter> recruiters;

  const RecruiterVerificationScreen({
    super.key,
    required this.recruiters,
  });

  @override
  State<RecruiterVerificationScreen> createState() =>
      _RecruiterVerificationScreenState();
}

class _RecruiterVerificationScreenState
    extends State<RecruiterVerificationScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredRecruiters = widget.recruiters
        .where((r) =>
            !r.isActive &&
            (r.pharmacyName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                r.pharmacistFirstName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                r.city
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title:  Text(
           AppLocalizations.of(context)!.recruiterVerificationPanel,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SEARCH LABEL
             Text(
              AppLocalizations.of(context)!.search_pending_recruiters,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            /// SEARCH FIELD
            TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchHintRecruiters,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// SECTION TITLE
            Text(
              AppLocalizations.of(context)!.pendingVerification,
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
                        AppLocalizations.of(context)!.noRecruitersForVerification,
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
                                builder: (_) => RecruiterDetailPage(
                                  recruiter: recruiter,
                                ),
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
      gradient: isActive
          ? LinearGradient(colors: [Colors.white, Colors.white])
          : LinearGradient(colors: [Colors.orange.shade200, Colors.orange.shade400]),
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
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                firstName,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 2),
              Text(
                city,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
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
            child:  Text(
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