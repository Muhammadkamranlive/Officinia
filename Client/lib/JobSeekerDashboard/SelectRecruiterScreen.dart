import 'package:client/AppColors/AppColors.dart';
import 'package:client/JobSeekerDashboard/SkillVerificationOutsideScreen.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SelectRecruiterScreen extends StatefulWidget {
  const SelectRecruiterScreen({super.key});

  @override
  State<SelectRecruiterScreen> createState() => _SelectRecruiterScreenState();
}

class _SelectRecruiterScreenState extends State<SelectRecruiterScreen> {
  final RecruiterRepository _repo = RecruiterRepository();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Recruiter> _allRecruiters = [];
  List<Recruiter> _filteredRecruiters = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRecruiters();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredRecruiters = _allRecruiters);
    } else {
      setState(() {
        _filteredRecruiters = _allRecruiters
            .where((r) => r.pharmacyName.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Future<void> _loadRecruiters() async {
    setState(() => _loading = true);
    final recruiters = await _repo.getAllFromCollection(); // fetch all recruiters
    setState(() {
      _allRecruiters = recruiters;
      _filteredRecruiters = recruiters;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(AppLocalizations.of(context)!.select_pharmacy_title, style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search_pharmacy_hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_filteredRecruiters.isEmpty)
              Expanded(
                  child: Center(child: Text(AppLocalizations.of(context)!.no_pharmacies_found)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRecruiters.length,
                  itemBuilder: (_, i) {
                    final recruiter = _filteredRecruiters[i];
                    return RecruiterGradientCard(
                      recruiter: recruiter,
                      onSelect: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SkillVerificationOutsideScreen(
                              recruiter: recruiter,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RecruiterCard extends StatelessWidget {
  final Recruiter recruiter;
  final VoidCallback onSelect;

  const RecruiterCard({
    super.key,
    required this.recruiter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔹 LOGO
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade100,
              ),
              child: recruiter.logoUrl != null &&
                      recruiter.logoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        recruiter.logoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.store,
                      size: 26,
                      color: Colors.grey,
                    ),
            ),

            const SizedBox(width: 14),

            /// 🔹 TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recruiter.pharmacyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// 🔹 CRESCENT BADGE 🌙
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nightlight_round, // 🌙 Muslim / Crescent
                size: 18,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 6),

            /// 🔹 ARROW
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class RecruiterGradientCard extends StatelessWidget {
  final Recruiter recruiter;
  final VoidCallback onSelect;

  const RecruiterGradientCard({
    super.key,
    required this.recruiter,
    required this.onSelect, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSelect,
          splashColor: AppColors.darkGreen.withOpacity(0.05),
          highlightColor: AppColors.darkGreen.withOpacity(0.02),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// PREMIUM LOGO WITH GRADIENT BORDER
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkGreen.withOpacity(0.1),
                        AppColors.darkGreen.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.darkGreen.withOpacity(0.12),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: recruiter.logoUrl != null &&
                              recruiter.logoUrl!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                recruiter.logoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultLogo();
                                },
                              ),
                            )
                          : _buildDefaultLogo(),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /// TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pharmacy Name with Premium Styling
                      Text(
                        recruiter.pharmacyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Recruiter Name with Icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: AppColors.darkGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGreen,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Location with Icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${recruiter.streetAddress}, ${recruiter.city}",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                /// PREMIUM ARROW BUTTON
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.darkGreen,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Default logo widget
  Widget _buildDefaultLogo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkGreen.withOpacity(0.12),
            AppColors.darkGreen.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.store_rounded,
        color: AppColors.darkGreen,
        size: 32,
      ),
    );
  }
}
class RecruiterWhiteCard extends StatelessWidget {
  final Recruiter recruiter;
  final VoidCallback onTap;

  const RecruiterWhiteCard({
    super.key,
    required this.recruiter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.greenCeladon.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.greenCeladon,
                size: 26,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recruiter.pharmacyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${recruiter.streetAddress}, ${recruiter.city}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
