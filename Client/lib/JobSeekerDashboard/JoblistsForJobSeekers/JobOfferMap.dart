import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/RecruiterWithJobStats.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Model/JobTypeModel.dart';
import 'package:client/Server/Model/ExperienceLevelModel.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobTypeRepository.dart';
import 'package:client/Server/Repo/ExperienceLevelRepository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../l10n/app_localizations.dart';


// ═══════════════════════════════════════════════════════════════════
//  FILTER MODEL
// ═══════════════════════════════════════════════════════════════════
class MapFilterResult {
  final String? wilaya;
  final String? district;
  final List<String> jobTitleIds;
  final List<String> jobTypes;
  final String? experienceLevel;

  const MapFilterResult({
    this.wilaya,
    this.district,
    this.jobTitleIds = const [],
    this.jobTypes = const [],
    this.experienceLevel,
  });

  bool get isEmpty =>
      wilaya == null &&
      district == null &&
      jobTitleIds.isEmpty &&
      jobTypes.isEmpty &&
      experienceLevel == null;

  int get activeCount {
    int n = 0;
    if (wilaya != null) n++;
    if (district != null) n++;
    if (jobTitleIds.isNotEmpty) n++;
    if (jobTypes.isNotEmpty) n++;
    if (experienceLevel != null) n++;
    return n;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PIN PAINTER  — Beautiful green Google Map style marker
// ═══════════════════════════════════════════════════════════════════
Future<Uint8List> _paintGooglePin({
  required String label,
  required bool selected,
}) async {
  const double dpr = 3.0; // Higher DPR for crispness
  final double pinSize = selected ? 100.0 : 80.0;
  
  final shortened = label.length > 12 ? '${label.substring(0, 10)}…' : label;
  final tp = TextPainter(
    text: TextSpan(
      text: shortened,
      style: TextStyle(
        color: selected ? const Color(0xFF1A3C28) : Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();

  final double textW = tp.width;
  final double textH = tp.height;

  final double w = textW > pinSize ? textW + 16 : pinSize + 16;
  final double h = (pinSize * 1.5) + textH + 10;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w * dpr, h * dpr));
  canvas.scale(dpr, dpr);

  final cx = w / 2;
  final double bulbR = pinSize / 2;
  final double pinH = pinSize * 1.35;

  // 1) Bottom shadow ellipse for grounding
  canvas.drawOval(
    Rect.fromCenter(center: Offset(cx, pinH), width: bulbR * 1.2, height: bulbR * 0.4),
    Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
  );

  // 2) Draw marker.png as the complete marker body
  try {
    final ByteData data      = await rootBundle.load('assets/marker.png');
    final ui.Codec codec     = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final ui.FrameInfo fi    = await codec.getNextFrame();
    final ui.Image markerImg = fi.image;

    final double imgW = pinSize;
    final double imgH = pinSize;
    
    // Draw the marker so its bottom is at pinH (matching the shadow and anchor)
    final Rect destRect = Rect.fromLTWH(cx - imgW/2, pinH - imgH, imgW, imgH);
    final Rect srcRect  = Rect.fromLTWH(0, 0, markerImg.width.toDouble(), markerImg.height.toDouble());
    
    canvas.drawImageRect(markerImg, srcRect, destRect, Paint()..filterQuality = ui.FilterQuality.high);
  } catch (e) {
    // Fallback if image missing: draw a simple green circle
    canvas.drawCircle(Offset(cx, bulbR), bulbR, Paint()..color = Colors.green);
  }

  // 3) Draw label
  final labelX = cx - textW / 2;
  final labelY = pinH + 6;

  final outlinePainter = TextPainter(
    text: TextSpan(
      text: shortened,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = Colors.white,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();
  outlinePainter.paint(canvas, Offset(labelX, labelY));
  tp.paint(canvas, Offset(labelX, labelY));

  final img = await recorder.endRecording().toImage((w * dpr).toInt(), (h * dpr).toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

// ═══════════════════════════════════════════════════════════════════
//  MAIN WIDGET
// ═══════════════════════════════════════════════════════════════════
class JobOfferMapView extends StatefulWidget {
  final List<RecruiterWithJobStats> recruiters;
  final List<JobOption> allOptions;
  final String locale;

  const JobOfferMapView({
    super.key,
    required this.recruiters,
    required this.allOptions,
    required this.locale,
  });

  @override
  State<JobOfferMapView> createState() => _JobOfferMapViewState();
}

class _JobOfferMapViewState extends State<JobOfferMapView>
    with SingleTickerProviderStateMixin {
  // ── Map ──────────────────────────────────────────────────────────
  GoogleMapController? _ctrl;
  Set<Marker> _markers = {};
  bool _mapReady = false;

  // ── Selection ────────────────────────────────────────────────────
  String? _selectedRecruiterId;

  // ── Bottom sheet ─────────────────────────────────────────────────
  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();

  // ── Filters ──────────────────────────────────────────────────────
  MapFilterResult _filter = const MapFilterResult();

  // ── Marker byte cache ────────────────────────────────────────────
  final Map<String, Uint8List> _cache = {};

  // ── Dynamic filter data ──────────────────────────────────────────
  bool _filtersLoading = false;
  List<ProvinceModel> _wilayas = [];
  Map<String, List<CityModel>> _districts = {};
  List<JobTypeModel> _jobTypes = [];
  List<ExperienceLevelModel> _experienceLvls = [];

  Future<void> _loadFilters() async {
    if (_wilayas.isNotEmpty || _filtersLoading) return;
    if (mounted) setState(() => _filtersLoading = true);
    try {
      final locRepo = LocationRepository();
      final exptRepo = ExperienceLevelRepository();
      final typeRepo = JobTypeRepository();

      final provinces = await locRepo.getProvinces();
      final List<MapEntry<String, List<CityModel>>> cityEntries = [];
      
      await Future.wait(provinces.map((p) async {
        if (p.docId != null) {
          final cities = await locRepo.getCities(p.docId!);
          if (cities.isNotEmpty) {
            cityEntries.add(MapEntry(p.en, cities));
          }
        }
      }));

      final types = await typeRepo.getJobTypes();
      final exp = await exptRepo.getExperienceLevels();

      if (mounted) {
        setState(() {
          _wilayas = provinces;
          _districts = Map.fromEntries(cityEntries);
          _jobTypes = types;
          _experienceLvls = exp;
          _filtersLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _filtersLoading = false);
    }
  }



  // ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  @override
  void didUpdateWidget(covariant JobOfferMapView old) {
    super.didUpdateWidget(old);
    if (old.recruiters != widget.recruiters && _mapReady) _buildMarkers();
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    _ctrl?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  //  Safe sheet animation — guards against not-yet-attached controller
  // ─────────────────────────────────────────────────────────────────
  void _safeAnimateSheet(double size,
      {Duration duration = const Duration(milliseconds: 380)}) {
    if (!_sheetCtrl.isAttached) return;
    _sheetCtrl.animateTo(
      size,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
  }

  // ── Selected Details ─────────────────────────────────────────────
  bool _loadingJobs = false;
  List<JobOfferWithRecruiter>? _selectedJobs;

  // ─────────────────────────────────────────────────────────────────
  //  Filtered list
  // ─────────────────────────────────────────────────────────────────
  List<RecruiterWithJobStats> get _visible {
    return widget.recruiters.where((s) {
      if (s.recruiter.latitude == 0.0 && s.recruiter.longitude == 0.0) return false;
      if (_filter.wilaya != null) {
        final wi = _filter.wilaya!.toLowerCase();
        if (!s.recruiter.city.toLowerCase().contains(wi) &&
            !s.recruiter.streetAddress.toLowerCase().contains(wi)) return false;
      }
      if (_filter.district != null) {
        final di = _filter.district!.toLowerCase();
        if (!s.recruiter.city.toLowerCase().contains(di) &&
            !s.recruiter.streetAddress.toLowerCase().contains(di)) return false;
      }
      // Note: JobType/JobTitle filters are omitted for local mapping until backend supports it
      return true;
    }).toList();
  }

  JobOption? _optionById(String id) {
    try {
      return widget.allOptions.firstWhere((o) => o.docId == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Build / refresh all markers
  // ─────────────────────────────────────────────────────────────────
  Future<void> _buildMarkers() async {
    final list = _visible;
    final Set<Marker> result = {};

    for (final stats in list) {
      final recruiterId = stats.recruiter.userId;
      final isSel = _selectedRecruiterId == recruiterId;
      final key = '${recruiterId}_${isSel ? 'sel' : 'def'}';

      if (!_cache.containsKey(key)) {
        _cache[key] = await _paintGooglePin(
          label: stats.recruiter.pharmacyName,
          selected: isSel,
        );
      }

      result.add(
        Marker(
          markerId: MarkerId(recruiterId),
          position: LatLng(stats.recruiter.latitude, stats.recruiter.longitude),
          icon: BitmapDescriptor.fromBytes(_cache[key]!),
          zIndex: isSel ? 10 : 1,
          anchor: const Offset(0.5, 0.72), // Points to the pin tip (pinH / h)
          onTap: () => _onPin(recruiterId),
        ),
      );
    }

    if (mounted) setState(() => _markers = result);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Pin tap
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onPin(String recruiterId) async {
    final same = _selectedRecruiterId == recruiterId;

    if (_selectedRecruiterId != null) {
      _cache
        ..remove('${_selectedRecruiterId!}_sel')
        ..remove('${_selectedRecruiterId!}_def');
    }

    if (same) {
      setState(() {
        _selectedRecruiterId = null;
        _selectedJobs = null;
      });
      _safeAnimateSheet(0.30);
    } else {
      _cache
        ..remove('${recruiterId}_sel')
        ..remove('${recruiterId}_def');
      setState(() {
         _selectedRecruiterId = recruiterId;
         _loadingJobs = true;
         _selectedJobs = null;
      });
      try {
        final r = _visible.firstWhere((g) => g.recruiter.userId == recruiterId);
        // Focus on selected pharmacy with a nice zoom level
        _ctrl?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                  r.recruiter.latitude - 0.0004, r.recruiter.longitude),
              zoom: 19.5,
              tilt: 45.0,
            ),
          ),
        );
      } catch (_) {}
      
      _safeAnimateSheet(0.52);

      // fetch jobs dynamically
      try {
        final repo = JobSearchRepository();
        final specificJobs = await repo.getJobsByRecruiter(recruiterId);
        if (mounted && _selectedRecruiterId == recruiterId) {
          setState(() {
            _selectedJobs = specificJobs;
            _loadingJobs = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loadingJobs = false);
      }
    }
    _buildMarkers();
  }

  // ─────────────────────────────────────────────────────────────────
  //  Dismiss selected
  // ─────────────────────────────────────────────────────────────────
  void _dismissSelected() {
    if (_selectedRecruiterId == null) return;
    final id = _selectedRecruiterId!;
    setState(() {
       _selectedRecruiterId = null;
       _selectedJobs = null;
    });
    _cache
      ..remove('${id}_sel')
      ..remove('${id}_def');
    _buildMarkers();
    _safeAnimateSheet(0.30);
  }

  void _onMapTap(LatLng _) => _dismissSelected();

  // ─────────────────────────────────────────────────────────────────
  //  Filter sheet
  // ─────────────────────────────────────────────────────────────────
  Future<void> _openFilter() async {
    if (_filtersLoading) return;
    if (_wilayas.isEmpty) {
      await _loadFilters();
    }
    if (!mounted) return;

    final res = await showModalBottomSheet<MapFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _FilterSheet(
        initial: _filter,
        allOptions: widget.allOptions,
        locale: widget.locale,
        wilayas: _wilayas,
        districts: _districts,
        jobTypes: _jobTypes,
        experienceLevels: _experienceLvls,
      ),
    );
    if (res != null && mounted) {
      setState(() {
        _filter = res;
        _selectedRecruiterId = null;
      });
      _cache.clear();
      _buildMarkers();
      _safeAnimateSheet(0.30,
          duration: const Duration(milliseconds: 320));
    }
  }

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final list = _visible;

    return Stack(
      children: [
        // ── Google Map ───────────────────────────────────────────
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(36.737, 3.086),
            zoom: 10,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (ctrl) async {
            _ctrl = ctrl;
            _mapReady = true;
            await ctrl.setMapStyle(null);
            _buildMarkers();
          },
          onTap: _onMapTap,
        ),

        // ── Top filter bar ───────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _TopBar(
              filter: _filter,
              count: list.length,
              onFilter: _openFilter,
              onClear: () {
                setState(() {
                  _filter = const MapFilterResult();
                  _selectedRecruiterId = null;
                });
                _cache.clear();
                _buildMarkers();
                _safeAnimateSheet(0.30,
                    duration: const Duration(milliseconds: 320));
              },
            ),
          ),
        ),

        // ── Draggable Bottom Sheet ───────────────────────────────
        DraggableScrollableSheet(
          controller: _sheetCtrl,
          initialChildSize: 0.30,
          minChildSize: 0.14,
          maxChildSize: 0.88,
          snap: true,
          snapSizes: const [0.14, 0.30, 0.52, 0.88],
          builder: (context, scrollCtrl) {
            RecruiterWithJobStats? selStat;
            if (_selectedRecruiterId != null) {
              try {
                selStat = list.firstWhere((r) => r.recruiter.userId == _selectedRecruiterId);
              } catch (_) {}
            }

            return _BottomSheet(
              scrollController: scrollCtrl,
              selectedJobs: _selectedJobs,
              loadingJobs: _loadingJobs,
              selectedStat: selStat,
              recruiters: list,
              allOptions: widget.allOptions,
              locale: widget.locale,
              onClose: _dismissSelected,
              onPharmacyTap: (id) => _onPin(id),
            );
          },
        ),

        // ── "No location" hint ───────────────────────────────────
        if (list.isEmpty && widget.recruiters.isNotEmpty && _mapReady)
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off_rounded,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.no_jobs_location_hint,
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════
class _BottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<JobOfferWithRecruiter>? selectedJobs;
  final bool loadingJobs;
  final RecruiterWithJobStats? selectedStat;
  final List<RecruiterWithJobStats> recruiters;
  final List<JobOption> allOptions;
  final String locale;
  final VoidCallback onClose;
  final ValueChanged<String> onPharmacyTap;

  const _BottomSheet({
    required this.scrollController,
    required this.selectedJobs,
    required this.loadingJobs,
    required this.selectedStat,
    required this.recruiters,
    required this.allOptions,
    required this.locale,
    required this.onClose,
    required this.onPharmacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedStat != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(), // Important for drag interactions
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 8),
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                  child: Row(
                    children: [
                      if (hasSelection) ...[
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: Color(0xFF1A3C28),
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.pharmacy_profile,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.pharmacies_on_map(recruiters.length),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.tap_pin_or_scroll_below,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A3C28), Color(0xFF2E7D52)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${recruiters.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),
          if (hasSelection)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  children: [
                    _PharmacyCard(stats: selectedStat!),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                         Text(
                          AppLocalizations.of(context)!.available_jobs_count(selectedStat!.jobCount),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (loadingJobs)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Color(0xFF1A3C28),
                        )),
                      )
                    else if (selectedJobs == null || selectedJobs!.isEmpty)
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: Text(AppLocalizations.of(context)!.no_active_jobs_available,
                                style: const TextStyle(color: Colors.grey))),
                      )
                    else
                      ...selectedJobs!.map((job) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _JobDetailCard(job: job),
                          )),
                  ],
                ),
              ),
            )
          else if (recruiters.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40, bottom: 40),
                child: _EmptyState(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PharmacyListTile(
                      stats: recruiters[i],
                      onTap: () => onPharmacyTap(recruiters[i].recruiter.userId),
                    ),
                  ),
                  childCount: recruiters.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PHARMACY LIST TILE
// ═══════════════════════════════════════════════════════════════════
class _PharmacyListTile extends StatelessWidget {
  final RecruiterWithJobStats stats;
  final VoidCallback onTap;
  const _PharmacyListTile({required this.stats, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _SmallAvatar(stats: stats),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.recruiter.pharmacyName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${stats.recruiter.streetAddress}, ${stats.recruiter.city}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3C28).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.available_jobs_count(stats.jobCount),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3C28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A3C28).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF1A3C28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  JOB DETAIL CARD
// ═══════════════════════════════════════════════════════════════════
class _JobDetailCard extends StatelessWidget {
  final JobOfferWithRecruiter job;
  const _JobDetailCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job hero
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A3C28).withOpacity(0.05),
                const Color(0xFF2E7D52).withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF2E7D52).withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(job: job),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.pharmacyName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D52),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.city,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Skills Required
        Text(
          AppLocalizations.of(context)!.required_skills_title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),

        if (job.skills.isEmpty)
          Text(
            AppLocalizations.of(context)!.no_skills_listed,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: job.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        // Action buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecruiterJobDetailScreen(job: job),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenCeladon,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              AppLocalizations.of(context)!.view_details,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PHARMACY CARD
// ═══════════════════════════════════════════════════════════════════
class _PharmacyCard extends StatelessWidget {
  final RecruiterWithJobStats stats;
  const _PharmacyCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3C28).withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D52).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(stats: stats),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.recruiter.pharmacyName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.recruiter.pharmacistFirstName} ${stats.recruiter.pharmacistLastName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D52),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${stats.recruiter.streetAddress}, ${stats.recruiter.city}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL AVATAR (list tile)
// ═══════════════════════════════════════════════════════════════════
class _SmallAvatar extends StatelessWidget {
  final RecruiterWithJobStats stats;
  const _SmallAvatar({required this.stats});

  String get _initials {
    final name = stats.recruiter.pharmacyName;
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A3C28).withOpacity(0.08),
          border: Border.all(
            color: const Color(0xFF2E7D52).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: stats.recruiter.logoUrl != null && stats.recruiter.logoUrl!.isNotEmpty
              ? Image.network(
                  stats.recruiter.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialsText(_initials),
                )
              : _InitialsText(_initials),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  AVATAR (detail card)
// ═══════════════════════════════════════════════════════════════════
class _Avatar extends StatelessWidget {
  final RecruiterWithJobStats? stats;
  const _Avatar({this.job, this.stats}) : assert(job != null || stats != null);
  final JobOfferWithRecruiter? job;

  String get _initials {
    final name = job?.pharmacyName ?? stats!.recruiter.pharmacyName;
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = job?.recruiter.logoUrl ?? stats!.recruiter.logoUrl;
    return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1A3C28).withOpacity(0.08),
          border: Border.all(
            color: const Color(0xFF2E7D52).withOpacity(0.25),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: logoUrl != null && logoUrl.isNotEmpty
              ? Image.network(
                  logoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _InitialsText(_initials, size: 20),
                )
              : _InitialsText(_initials, size: 20),
        ),
      );
  }
}

class _InitialsText extends StatelessWidget {
  final String text;
  final double size;
  const _InitialsText(this.text, {this.size = 16});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A3C28),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.no_profiles_match_filters,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final MapFilterResult _f;
  final int count;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  const _TopBar({
    required MapFilterResult filter,
    required this.count,
    required this.onFilter,
    required this.onClear,
  }) : _f = filter;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onFilter,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _f.isEmpty
                          ? Colors.grey.shade200
                          : const Color(0xFF1A3C28),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: _f.isEmpty
                            ? Colors.grey.shade500
                            : const Color(0xFF1A3C28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _f.isEmpty
                            ? Text(
                                AppLocalizations.of(context)!.filter_jobs_title,
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14),
                              )
                            : _ActiveChips(filter: _f),
                      ),
                      if (_f.activeCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3C28),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_f.activeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (!_f.isEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Colors.grey.shade600),
                ),
              ),
            ],
          ],
        ),
      );
}

class _ActiveChips extends StatelessWidget {
  final MapFilterResult filter;
  const _ActiveChips({required this.filter});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (filter.wilaya != null) filter.wilaya!,
      if (filter.district != null) filter.district!,
      ...filter.jobTitleIds.take(1),
      ...filter.jobTypes.take(1),
      if (filter.experienceLevel != null) filter.experienceLevel!,
    ];
    final show = items.take(2).toList();
    final over = items.length - show.length;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        ...show.map((c) => _MiniChip(c)),
        if (over > 0) _MiniChip('+$over', muted: true),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final bool muted;
  const _MiniChip(this.label, {this.muted = false});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: muted
              ? Colors.grey.shade100
              : const Color(0xFF1A3C28).withOpacity(0.10),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: muted
                ? Colors.grey.shade500
                : const Color(0xFF1A3C28),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════
//  FILTER SHEET
// ═══════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final MapFilterResult initial;
  final List<JobOption> allOptions;
  final String locale;
  final List<ProvinceModel> wilayas;
  final Map<String, List<CityModel>> districts;
  final List<JobTypeModel> jobTypes;
  final List<ExperienceLevelModel> experienceLevels;

  const _FilterSheet({
    required this.initial,
    required this.allOptions,
    required this.locale,
    required this.wilayas,
    required this.districts,
    required this.jobTypes,
    required this.experienceLevels,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _wilaya;
  late String? _district;
  late List<String> _jobTitleIds;
  late List<String> _jobTypes;
  late String? _experience;

  @override
  void initState() {
    super.initState();
    _wilaya = widget.initial.wilaya;
    _district = widget.initial.district;
    _jobTitleIds = List.from(widget.initial.jobTitleIds);
    _jobTypes = List.from(widget.initial.jobTypes);
    _experience = widget.initial.experienceLevel;
  }

  List<JobOption> get _titles => widget.allOptions
      .where((o) => o.isActive && o.type == JobOptionType.jobTitle)
      .toList();

  List<CityModel> get _availableDistricts =>
      _wilaya != null ? (widget.districts[_wilaya] ?? []) : [];

  int get _count {
    int n = 0;
    if (_wilaya != null) n++;
    if (_district != null) n++;
    if (_jobTitleIds.isNotEmpty) n++;
    if (_jobTypes.isNotEmpty) n++;
    if (_experience != null) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.filter_jobs_title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const Spacer(),
                if (_count > 0)
                  GestureDetector(
                    onTap: () => setState(() {
                      _wilaya = null;
                      _district = null;
                      _jobTitleIds = [];
                      _jobTypes = [];
                      _experience = null;
                    }),
                    child: Text(
                      AppLocalizations.of(context)!.clear_all,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              children: [
                _Sec(AppLocalizations.of(context)!.wilaya, Icons.map_outlined),
                const SizedBox(height: 10),
                _ChipGrid<ProvinceModel>(
                  items: widget.wilayas,
                  selected: _wilaya == null ? [] : [_wilaya!],
                  multi: false,
                  searchable: true,
                  id: (p) => p.en,
                  label: (p) => p.label(widget.locale),
                  onChanged: (sel) => setState(() {
                    _wilaya = sel.isEmpty ? null : sel.first;
                    _district = null;
                  }),
                ),
                if (_availableDistricts.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _Sec(AppLocalizations.of(context)!.district, Icons.location_city_outlined),
                  const SizedBox(height: 10),
                  _ChipGrid<CityModel>(
                    items: _availableDistricts,
                    selected: _district == null ? [] : [_district!],
                    multi: false,
                    id: (c) => c.en,
                    label: (c) => c.label(widget.locale),
                    onChanged: (sel) => setState(
                      () => _district =
                          sel.isEmpty ? null : sel.first,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _Sec(AppLocalizations.of(context)!.job_title, Icons.work_outline_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _titles.map((opt) {
                    final lbl = opt.label(widget.locale);
                    final id = opt.docId;
                    final sel =
                        id != null && _jobTitleIds.contains(id);
                    return _Chip(
                      label: lbl,
                      selected: sel,
                      onTap: () {
                        if (id == null) return;
                        setState(() {
                          if (sel) {
                            _jobTitleIds.remove(id);
                          } else {
                            _jobTitleIds.add(id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _Sec(AppLocalizations.of(context)!.job_type_label, Icons.schedule_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.jobTypes.map((t) {
                    final tid = t.en;
                    final sel = _jobTypes.contains(tid);
                    return _Chip(
                      label: t.label(widget.locale),
                      selected: sel,
                      icon: _icon(tid),
                      onTap: () => setState(() =>
                          sel ? _jobTypes.remove(tid) : _jobTypes.add(tid)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                _Sec(AppLocalizations.of(context)!.experience, Icons.bar_chart_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.experienceLevels.map((lv) {
                    final lvid = lv.en;
                    final sel = _experience == lvid;
                    return _Chip(
                      label: lv.label(widget.locale),
                      selected: sel,
                      onTap: () => setState(
                          () => _experience = sel ? null : lvid),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            child: Row(
              children: [
                if (_count > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.active_filters_count(_count),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        MapFilterResult(
                          wilaya: _wilaya,
                          district: _district,
                          jobTitleIds: _jobTitleIds,
                          jobTypes: _jobTypes,
                          experienceLevel: _experience,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C28),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.show_results,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String t) => switch (t) {
        'Full-time' => Icons.access_time_filled_rounded,
        'Part-time' => Icons.timelapse_rounded,
        'Temporary' => Icons.event_rounded,
        'Internship' => Icons.school_outlined,
        _ => Icons.work_outline_rounded,
      };
}

class _Sec extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Sec(this.title, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1A3C28)),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
        ],
      );
}

class _ChipGrid<T> extends StatefulWidget {
  final List<T> items;
  final List<String> selected;
  final bool multi;
  final bool searchable;
  final ValueChanged<List<String>> onChanged;
  final String Function(T) id;
  final String Function(T) label;

  const _ChipGrid({
    required this.items,
    required this.selected,
    required this.multi,
    required this.onChanged,
    required this.id,
    required this.label,
    this.searchable = false,
  });

  @override
  State<_ChipGrid<T>> createState() => _ChipGridState<T>();
}

class _ChipGridState<T> extends State<_ChipGrid<T>> {
  String _q = '';

  List<T> get _filtered => _q.isEmpty
      ? widget.items
      : widget.items
          .where((i) => widget.label(i).toLowerCase().contains(_q.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.searchable && widget.items.length > 8) ...[
            TextField(
              onChanged: (v) => setState(() => _q = v),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.search_wilaya,
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF1A3C28)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filtered.map((item) {
              final tId = widget.id(item);
              final tLabel = widget.label(item);
              final sel = widget.selected.contains(tId);
              return _Chip(
                label: tLabel,
                selected: sel,
                onTap: () {
                  final next = List<String>.from(widget.selected);
                  if (widget.multi) {
                    sel ? next.remove(tId) : next.add(tId);
                  } else {
                    next.clear();
                    if (!sel) next.add(tId);
                  }
                  widget.onChanged(next);
                },
              );
            }).toList(),
          ),
        ],
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
              horizontal: icon != null ? 10 : 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF1A3C28)
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1A3C28)
                  : Colors.grey.shade300,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      );
}
