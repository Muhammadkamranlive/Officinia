import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/GoogleMap/LocationPickerScreen.dart';
import 'package:client/Profile/ProfileLogoUploadScreen.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';

import '../../l10n/app_localizations.dart';

// ── Import the location picker we built ──────────────────────
// Adjust path to wherever you placed location_picker_screen.dart

class RecruiterAccountScreen extends StatefulWidget {
  final AccountFormMode mode;
  const RecruiterAccountScreen({super.key, required this.mode});

  @override
  State<RecruiterAccountScreen> createState() => _RecruiterAccountScreenState();
}

class _RecruiterAccountScreenState extends State<RecruiterAccountScreen> {
  final _repo = RecruiterRepository();
  final _locationRepo = LocationRepository();

  final pharmacyNameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  static const double inputFieldHeight = 66;

  List<ProvinceModel> _provinceOptions = [];
  List<CityModel> _cityOptions = [];

  String? selectedProvince;
  String? selectedCity;

  // ── location picked via map ───────────────────────────────────
  double _latitude = 0;
  double _longitude = 0;
  String _streetAddress = '';

  Recruiter? recruiter;
  bool loading = true;

  bool get isView => widget.mode == AccountFormMode.view;
  bool get isEdit => widget.mode == AccountFormMode.edit;
  bool get isCreate => widget.mode == AccountFormMode.create;

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
    super.dispose();
  }

  // ── load ──────────────────────────────────────────────────────
  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final results = await Future.wait([
      _locationRepo.getProvinces(),
      _repo.getByUid(user.userId),
    ]);

    _provinceOptions = results[0] as List<ProvinceModel>;
    recruiter = results[1] as Recruiter?;

    if (recruiter != null) {
      pharmacyNameCtrl.text = recruiter!.pharmacyName;
      firstNameCtrl.text = recruiter!.pharmacistFirstName;
      lastNameCtrl.text = recruiter!.pharmacistLastName;
      _latitude = recruiter!.latitude;
      _longitude = recruiter!.longitude;
      _streetAddress = recruiter!.streetAddress;

      final matchedProvince = _provinceOptions
          .where((p) => p.en == recruiter!.province)
          .firstOrNull;

      if (matchedProvince != null) {
        selectedProvince = matchedProvince.docId;
        _cityOptions = await _locationRepo.getCities(matchedProvince.docId!);
        selectedCity = _cityOptions
            .where((c) => c.en == recruiter!.city)
            .firstOrNull
            ?.docId;
      }
    }

    setState(() => loading = false);
  }

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

  // ── open location picker ──────────────────────────────────────
  Future<void> _openLocationPicker() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final updated = await Navigator.push<Recruiter>(
      context,
      MaterialPageRoute(
        builder: (_) => RecruiterLocationPicker(
          recruiter: recruiter!, // pass your loaded Recruiter object
        ),
      ),
    );

    // update local state if user confirmed
    if (updated != null && mounted) {
      setState(() {
        recruiter = updated;
        _streetAddress = updated.streetAddress;
        _latitude = updated.latitude;
        _longitude = updated.longitude;
      });
    }
  }

  // ── save ──────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => loading = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final provinceEN =
        _provinceOptions
            .where((p) => p.docId == selectedProvince)
            .firstOrNull
            ?.en ??
        '';
    final cityEN =
        _cityOptions.where((c) => c.docId == selectedCity).firstOrNull?.en ??
        '';

    final data = Recruiter(
      userId: user.userId,
      pharmacyName: pharmacyNameCtrl.text,
      pharmacistFirstName: firstNameCtrl.text,
      pharmacistLastName: lastNameCtrl.text,
      province: provinceEN,
      city: cityEN,
      streetAddress: _streetAddress, // from map picker
      latitude: _latitude, // from map picker
      longitude: _longitude, // from map picker
      createdAt: recruiter?.createdAt ?? DateTime.now(),
      isActive: true,
      docId: recruiter?.docId,
      logoUrl: recruiter?.logoUrl ?? '',
    );

    if (isCreate) {
      await _repo.add(data);
    } else {
      await _repo.update(data.docId!, data);
    }

    setState(() => loading = false);
    Navigator.pushNamed(context, AppRoutes.mainShell);
  }

  // ── build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isCreate
              ? l10n.create_account_title
              : isEdit
              ? l10n.edit_profile_title
              : l10n.my_account_title,
          style: const TextStyle(color: AppColors.darkGreen),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // profile picture — edit/view only
              if (!isCreate) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecruiterProfileScreen(recruiter: recruiter!),
                      ),
                    );
                  },
                  child: Text(l10n.update_profile_picture),
                ),
                const SizedBox(height: 20),
              ],

              // personal info
              _card(
                l10n.personal_information,
                Column(
                  children: [
                    _InputField(
                      label: l10n.first_name,
                      hint: l10n.first_name_hint,
                      enabled: !isView,
                      controller: firstNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _InputField(
                      label: l10n.last_name,
                      hint: l10n.last_name_hint,
                      enabled: !isView,
                      controller: lastNameCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // pharmacy & location
              _card(
                l10n.pharmacy_location_title,
                Column(
                  children: [
                    _InputField(
                      label: l10n.pharmacy_name,
                      hint: l10n.pharmacy_name_hint,
                      enabled: !isView,
                      controller: pharmacyNameCtrl,
                    ),
                    const SizedBox(height: 12),
                    _provinceDropdown(l10n),
                    const SizedBox(height: 12),
                    _cityDropdown(l10n),
                    const SizedBox(height: 12),
                    if (!isCreate) ...[
                      // ── LOCATION PICKER (replaces street address field) ──
                      _locationPickerTile(l10n),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (!isView)
                _customButton(
                  text: isCreate ? l10n.create_account_btn : l10n.save_changes,
                  onPressed: _save,
                  size: MediaQuery.of(context).size,
                  gradient: AppColors.gradientdarkgreen,
                  shadowColor: AppColors.darkGreen,
                ),

              if (isView)
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.edit_profile),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecruiterAccountScreen(
                        mode: AccountFormMode.edit,
                      ),
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
                child: Text(l10n.logout),
              ),
              const SizedBox(height: 24),
              BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                child: Text(
                  '© 2026 Ophicina. ${l10n.all_rights_reserved}.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── location picker tile ──────────────────────────────────────
  Widget _locationPickerTile(AppLocalizations l10n) {
    final hasLocation = _latitude != 0 && _longitude != 0;

    return GestureDetector(
      onTap: isView ? null : _openLocationPicker,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.gradientgreen,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // icon badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? AppColors.darkGreen.withOpacity(.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasLocation
                      ? Icons.location_on_rounded
                      : Icons.add_location_alt_rounded,
                  color: hasLocation
                      ? AppColors.darkGreen
                      : Colors.grey.shade500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // address text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pharmacy_location_tile,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _streetAddress.isNotEmpty
                          ? _streetAddress
                          : l10n.tap_to_set_location,
                      style: TextStyle(
                        fontSize: 14,
                        color: _streetAddress.isNotEmpty
                            ? Colors.black87
                            : Colors.grey.shade400,
                        fontWeight: _streetAddress.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // show lat/lng hint when location set
                    if (hasLocation) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${_latitude.toStringAsFixed(4)}, '
                        '${_longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGreen.withOpacity(.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // trailing action
              if (!isView) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasLocation ? l10n.change_btn : l10n.set_btn,
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── province dropdown ─────────────────────────────────────────
  Widget _provinceDropdown(AppLocalizations l10n) {
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
            labelText: l10n.wilaya,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          ),
          hint: Text(l10n.select_province),
          items: _provinceOptions
              .map((p) => DropdownMenuItem(
                    value: p.docId,
                    child: Text(p.label(Localizations.localeOf(context).languageCode)),
                  ))
              .toList(),
          onChanged: isView ? null : _onProvinceChanged,
        ),
      ),
    );
  }

  // ── city dropdown ─────────────────────────────────────────────
  Widget _cityDropdown(AppLocalizations l10n) {
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
            labelText: l10n.city,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          ),
          hint: Text(
            selectedProvince == null
                ? l10n.select_province_first
                : _cityOptions.isEmpty
                ? l10n.loading_dots
                : l10n.select_city,
          ),
          items: _cityOptions
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c.docId,
                  child: Text(c.label(Localizations.localeOf(context).languageCode)),
                ),
              )
              .toList(),
          onChanged: (isView || selectedProvince == null)
              ? null
              : (val) => setState(() => selectedCity = val),
        ),
      ),
    );
  }

  // ── card wrapper ──────────────────────────────────────────────
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

// ── Input Field ───────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final String label, hint;
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

// ── Custom Button ─────────────────────────────────────────────

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
