import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Profile/AdminUloadLogoScreen.dart';
import 'package:client/Server/Enums/AdminEnum.dart';
import 'package:client/Server/Model/AdminsModel.dart';
import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Repo/AdminRepo.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/l10n/app_localizations.dart';

// REMOVED: hardcoded const List<String> provinces
// REMOVED: hardcoded const Map<String, List<String>> cities
// Both now come from Firestore via LocationRepository

class AdminAccountScreen extends StatefulWidget {
  final AdminFormMode mode;

  const AdminAccountScreen({super.key, required this.mode});

  @override
  State<AdminAccountScreen> createState() => _AdminAccountScreenState();
}

class _AdminAccountScreenState extends State<AdminAccountScreen> {
  final _repo = AdminRepository();
  final _locationRepo = LocationRepository();

  final pharmacyNameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  static const double inputFieldHeight = 66;

  // ── Firestore-loaded option lists ──────────────────────────────
  List<ProvinceModel> _provinceOptions = [];
  List<CityModel> _cityOptions = [];

  // ── Selected values — store docId in memory, EN name in Firestore ──
  String? selectedProvince; // ProvinceModel.docId
  String? selectedCity; // CityModel.docId

  AdminsModel? recruiter;
  bool loading = true;

  bool get isView => widget.mode == AdminFormMode.view;
  bool get isEdit => widget.mode == AdminFormMode.edit;
  bool get isCreate => widget.mode == AdminFormMode.create;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    pharmacyNameCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    streetCtrl.dispose();
    super.dispose();
  }

  // ── Load provinces + admin profile in parallel ─────────────────
  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final results = await Future.wait([
      _locationRepo.getProvinces(), // [0]
      _repo.getByUid(user.userId), // [1]
    ]);

    _provinceOptions = results[0] as List<ProvinceModel>;
    recruiter = results[1] as AdminsModel?;

    if (recruiter != null) {
      pharmacyNameCtrl.text = recruiter!.pharmacyName;
      firstNameCtrl.text = recruiter!.pharmacistFirstName;
      lastNameCtrl.text = recruiter!.pharmacistLastName;
      streetCtrl.text = recruiter!.streetAddress;

      // Restore province: match stored EN name → docId
      final matchedProvince = _provinceOptions
          .where((p) => p.en == recruiter!.province)
          .firstOrNull;

      if (matchedProvince != null) {
        selectedProvince = matchedProvince.docId;
        // Load cities for this province, then match stored city EN → docId
        _cityOptions = await _locationRepo.getCities(matchedProvince.docId!);
        selectedCity = _cityOptions
            .where((c) => c.en == recruiter!.city)
            .firstOrNull
            ?.docId;
      }
    }

    setState(() => loading = false);
  }

  // ── When province changes, fetch its cities ────────────────────
  Future<void> _onProvinceChanged(String? provinceDocId) async {
    setState(() {
      selectedProvince = provinceDocId;
      selectedCity = null;
      _cityOptions = [];
    });
    if (provinceDocId == null) return;
    final cities = await _locationRepo.getCities(provinceDocId);
    if (mounted) setState(() => _cityOptions = cities);
  }

  // ── Save ───────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => loading = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    // Resolve docId → EN name for storage (always store EN key)
    final provinceEN =
        _provinceOptions
            .where((p) => p.docId == selectedProvince)
            .firstOrNull
            ?.en ??
        '';
    final cityEN =
        _cityOptions.where((c) => c.docId == selectedCity).firstOrNull?.en ??
        '';

    final data = AdminsModel(
      userId: user.userId,
      pharmacyName: pharmacyNameCtrl.text,
      pharmacistFirstName: firstNameCtrl.text,
      pharmacistLastName: lastNameCtrl.text,
      province: provinceEN, // EN key stored
      city: cityEN, // EN key stored
      streetAddress: streetCtrl.text,
      latitude: recruiter?.latitude ?? 0,
      longitude: recruiter?.longitude ?? 0,
      createdAt: recruiter?.createdAt ?? DateTime.now(),
      isActive: true,
      docId: recruiter?.docId,
    );

    if (isCreate) {
      await _repo.add(data);
    } else {
      await _repo.update(data.docId!, data);
    }

    setState(() => loading = false);
    Navigator.pushNamed(context, AppRoutes.adminDash);
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isCreate
              ? AppLocalizations.of(context)!.create_account_title
              : isEdit
              ? AppLocalizations.of(context)!.edit_profile_title
              : AppLocalizations.of(context)!.my_account_title,
          style: const TextStyle(color: AppColors.darkGreen),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile picture button — edit/view only
              if (!isCreate) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminProfileScreen(recruiter: recruiter!),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.update_profile_picture),
                ),
                const SizedBox(height: 20),
              ],

              // Personal info
              _card(
                AppLocalizations.of(context)!.personal_information,
                Column(
                  children: [
                    _InputField(
                      label: AppLocalizations.of(context)!.first_name,
                      hint: AppLocalizations.of(context)!.first_name_hint,
                      enabled: !isView,
                      controller: firstNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _InputField(
                      label: AppLocalizations.of(context)!.last_name,
                      hint: AppLocalizations.of(context)!.last_name_hint,
                      enabled: !isView,
                      controller: lastNameCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Company & location
              _card(
                AppLocalizations.of(context)!.company_info_section,
                Column(
                  children: [
                    _InputField(
                      label: AppLocalizations.of(context)!.pharmacy_name,
                      hint: AppLocalizations.of(context)!.pharmacy_name_hint,
                      enabled: !isView,
                      controller: pharmacyNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _provinceDropdown(),
                    const SizedBox(height: 12),
                    _cityDropdown(),
                    const SizedBox(height: 12),
                    _InputField(
                      label: AppLocalizations.of(context)!.street_address_label,
                      hint: '12 Rue Didouche Mourad',
                      enabled: !isView,
                      controller: streetCtrl,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!isView)
                _customButton(
                  text: isCreate
                      ? AppLocalizations.of(context)!.create_account_title
                      : AppLocalizations.of(context)!.save_changes,
                  onPressed: _save,
                  size: MediaQuery.of(context).size,
                  gradient: AppColors.gradientdarkgreen,
                  shadowColor: AppColors.darkGreen,
                ),

              if (isView)
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(AppLocalizations.of(context)!.edit_profile),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AdminAccountScreen(mode: AdminFormMode.edit),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
                child: Text(AppLocalizations.of(context)!.logout),
              ),
              const SizedBox(height: 24),
              BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                child: Text(
                  AppLocalizations.of(context)!.all_rights_reserved,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Province dropdown — Firestore provinces ────────────────────
  Widget _provinceDropdown() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        height: inputFieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedProvince,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.province_label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          ),
          hint: Text(AppLocalizations.of(context)!.select_province),
          items: _provinceOptions
              .map((p) => DropdownMenuItem(value: p.docId, child: Text(p.en)))
              .toList(),
          onChanged: isView ? null : _onProvinceChanged,
        ),
      ),
    );
  }

  // ── City dropdown — Firestore cities subcollection ─────────────
  Widget _cityDropdown() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        height: inputFieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedCity,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.city_label,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          ),
          hint: Text(
            selectedProvince == null
                ? AppLocalizations.of(context)!.select_province_first
                : _cityOptions.isEmpty
                ? AppLocalizations.of(context)!.loading_dots
                : AppLocalizations.of(context)!.select_city,
          ),
          items: _cityOptions
              .map(
                (c) =>
                    DropdownMenuItem<String>(value: c.docId, child: Text(c.en)),
              )
              .toList(),
          onChanged: (isView || selectedProvince == null)
              ? null
              : (val) => setState(() => selectedCity = val),
        ),
      ),
    );
  }

  // ── Shared card wrapper ────────────────────────────────────────
  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool enabled;
  final int maxLines;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.enabled,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom Button ─────────────────────────────────────────────────────────────

Widget _customButton({
  required String text,
  required void Function()? onPressed,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
