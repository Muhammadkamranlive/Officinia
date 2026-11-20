import 'package:client/Guard/AuthProvider/AuthProvider.dart';
// ← your map widget file
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/PharmacyMapWidget.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Repo/JobSeekers/SkillVerificationMetaRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';

class JobSeekerDetailScreen extends StatefulWidget {
  final JobSeekerModel seeker;

  /// Optional: pass the viewer's current location so the map can
  /// draw the route from them to the job seeker.
  final LatLng? viewerLocation;

  const JobSeekerDetailScreen({
    super.key,
    required this.seeker,
    this.viewerLocation, // nullable — map still works without it
  });

  @override
  State<JobSeekerDetailScreen> createState() => _JobSeekerDetailScreenState();
}

class _JobSeekerDetailScreenState extends State<JobSeekerDetailScreen> {
  final SkillMetaRepository _skillMetaRepo = SkillMetaRepository();

  int _verifiedCount = 0;
  Map<String, String> _skillsWithStatus = {};
  bool _loading = true;

  /// True when the job seeker has saved a valid map location.
  bool get _hasLocation =>
      widget.seeker.latitude != 0 && widget.seeker.longitude != 0;

  @override
  void initState() {
    super.initState();
    _loadSkillStatuses();
  }

  Future<void> _loadSkillStatuses() async {
    try {
      final skillMetas = await _skillMetaRepo.getSkillsForJobSeeker(
        widget.seeker.userId,
      );

      final Map<String, String> statuses = {};
      for (var skill in widget.seeker.skills) {
        final meta = skillMetas.firstWhere(
          (m) => m.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: widget.seeker.userId,
            skill: skill,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        statuses[skill] = meta.status;
      }

      final verifiedCount =
          statuses.values.where((s) => s == 'Verified').length;

      if (mounted) {
        setState(() {
          _skillsWithStatus = statuses;
          _verifiedCount = verifiedCount;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _premiumHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _contactInfoCard(),
                  const SizedBox(height: 20),
                  _skillsSection(),
                  const SizedBox(height: 20),
                  _experienceCard(),
                  const SizedBox(height: 20),
                  _educationCard(),

                  // ── MAP SECTION ──────────────────────────
                  // Always shown — map if coordinates exist, placeholder if not.
                  const SizedBox(height: 20),
                  _locationSection(),

                  const SizedBox(height: 24),
                  _actions(context, widget.seeker),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── MAP SECTION WIDGET ──────────────────────────────────────
  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientgreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.job_seeker_location,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        // ── Map OR placeholder ───────────────────────────
        if (_hasLocation)
          PharmacyMapWidget(
            pharmacyLL: LatLng(
              widget.seeker.latitude,
              widget.seeker.longitude,
            ),
            pharmacyName: widget.seeker.isNameVisible
                ? '${widget.seeker.firstName} ${widget.seeker.lastName}'
                : AppLocalizations.of(context)!.candidate_location,
            pharmacyAddress: widget.seeker.streetAddress,
            pharmacyCity: widget.seeker.city,
            pharmacyProvince: widget.seeker.province,
            seekerLL: widget.viewerLocation,
          )
        else
          _locationNotSharedCard(),
      ],
    );
  }

  /// Shown when latitude == 0 && longitude == 0 (no location saved yet).
  Widget _locationNotSharedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.greenCeladon.withOpacity(.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.greenCeladon.withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 28,
              color: AppColors.greenCeladon.withOpacity(.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.location_not_shared,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.location_not_shared_desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  //  Everything below is unchanged from your original file
  // ───────────────────────────────────────────────────────────

  SliverAppBar _premiumHeader(BuildContext context) {
    final bool hasVerifiedSkills = _verifiedCount > 0;

    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.greenCeladon,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientgreen),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: (widget.seeker.logoUrl != null &&
                              widget.seeker.logoUrl!.isNotEmpty)
                          ? Image.network(
                              widget.seeker.logoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/avatar.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/avatar.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.seeker.isNameVisible ? '${widget.seeker.firstName} ${widget.seeker.lastName}' : AppLocalizations.of(context)!.anonymous_candidate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.seeker.desiredPosition,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _statusChip(hasVerifiedSkills),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified ? Colors.white : AppColors.textLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning_rounded,
            size: 14,
            color: isVerified ? AppColors.greenCeladon : Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? AppLocalizations.of(context)!.verified_skills : AppLocalizations.of(context)!.unverified,
            style: TextStyle(
              color: isVerified ? AppColors.greenCeladon : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillsSection() {
    return _card(
      title: AppLocalizations.of(context)!.skills,
      child: Column(
        children: _skillsWithStatus.entries.map((entry) {
          final skillName = entry.key;
          final status = entry.value;
          final verified = status == 'Verified';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: verified
                  ? AppColors.lightgreen.withOpacity(0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  verified ? Icons.verified : Icons.circle_outlined,
                  size: 20,
                  color: verified ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    skillName,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _contactInfoCard() {
    if (widget.seeker.city.isEmpty &&
        widget.seeker.province.isEmpty &&
        widget.seeker.streetAddress.isEmpty &&
        (widget.seeker.phoneNumber ).isEmpty) {
      return const SizedBox();
    }

    return _card(
      title: AppLocalizations.of(context)!.contact_and_location,
      child: Column(
        children: [
          if (widget.seeker.city.isNotEmpty)
            _infoRow(Icons.location_city, AppLocalizations.of(context)!.city, widget.seeker.city),
          if (widget.seeker.province.isNotEmpty)
            _infoRow(Icons.map, AppLocalizations.of(context)!.wilaya, widget.seeker.province),
          if (widget.seeker.streetAddress.isNotEmpty)
            _infoRow(
                Icons.home_rounded, AppLocalizations.of(context)!.address, widget.seeker.streetAddress),
          if ((widget.seeker.phoneNumber ?? '').isNotEmpty)
            _infoRow(Icons.phone_rounded, AppLocalizations.of(context)!.phone_label, widget.seeker.phoneNumber),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.gradientgreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard() {
    if (widget.seeker.experienceDetails == null ||
        widget.seeker.experienceDetails!.isEmpty) return const SizedBox();

    return _card(
      title: AppLocalizations.of(context)!.experience,
      child: Text(
        widget.seeker.experienceDetails!,
        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
      ),
    );
  }

  Widget _educationCard() {
    if (widget.seeker.educationBackground == null ||
        widget.seeker.educationBackground!.isEmpty) return const SizedBox();

    return _card(
      title: AppLocalizations.of(context)!.education,
      child: Text(
        widget.seeker.educationBackground!,
        style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
      ),
    );
  }

  Widget _actions(BuildContext context, JobSeekerModel seeker) {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return const Row();
    final role = auth.user!.role;

    if (role == UserRole.admin) {
      return Row(
        children: [
          Expanded(
            child: _gradientButton(
              text: AppLocalizations.of(context)!.block_profile,
              gradient: AppColors.gradientPink,
              onTap: () => _showBlockUserSheet(context, seeker),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _gradientButton(
              text: AppLocalizations.of(context)!.chat,
              gradient: AppColors.gradientgreen1,
              onTap: () => _openChat(context, seeker),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: _gradientButton(
            text: AppLocalizations.of(context)!.chat,
            gradient: AppColors.gradientgreen1,
            onTap: () => _openChat(context, seeker),
          ),
        ),
      ],
    );
  }

  Future<void> _openChat(BuildContext context, JobSeekerModel seeker) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final chatService = ChatService();
    final chatId = await chatService.getOrCreateChat(
      auth.user!.userId,
      seeker.userId,
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          otherUserId: seeker.userId,
          personName: seeker.isNameVisible
              ? '${seeker.firstName} ${seeker.lastName}'
              : AppLocalizations.of(context)!.anonymous_candidate,
        ),
      ),
    );
  }

  void _showBlockUserSheet(BuildContext context, JobSeekerModel seeker) {
    final TextEditingController reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.block_user_account,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.block_user_reason_desc,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enter_block_reason,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        if (reasonCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(AppLocalizations.of(context)!.reason_is_required)),
                          );
                          return;
                        }
                        await _blockUser(
                            context, seeker.userId, reasonCtrl.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context)!.confirm_block,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _blockUser(
    BuildContext context,
    String userId,
    String reason,
  ) async {
    final auth = context.read<AuthProvider>();
    final admin = auth.user;
    if (admin == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty) return;
      await snapshot.docs.first.reference.update({
        'isBlocked': true,
        'blockReason': reason,
        'blockedBy': admin.userId,
        'blockedAt': DateTime.now().toIso8601String(),
      });
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.user_account_blocked)),
      );
    }
  }

  Widget _gradientButton({
    required String text,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}