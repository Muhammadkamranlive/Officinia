import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;


import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Server/Model/JobOption.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/SkillVerificationMeta.dart';
import 'package:client/Server/Model/CityModel.dart';
import 'package:client/Server/Model/ProvinceModel.dart';
import 'package:client/Server/Model/JobTypeModel.dart';
import 'package:client/Server/Model/ExperienceLevelModel.dart';
import 'package:client/Server/Repo/LocationRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobTypeRepository.dart';
import 'package:client/Server/Repo/ExperienceLevelRepository.dart';
import 'package:client/Server/Repo/JobSeekers/SkillMetaRepository.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

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
class JobSeekerMapView extends StatefulWidget {
  final List<JobSeekerModel> seekers;
  final List<JobOption> allOptions;
  final String locale;

  const JobSeekerMapView({
    super.key,
    required this.seekers,
    required this.allOptions,
    required this.locale,
  });

  @override
  State<JobSeekerMapView> createState() => _JobSeekerMapViewState();
}

class _JobSeekerMapViewState extends State<JobSeekerMapView>
    with SingleTickerProviderStateMixin {
  // ── Map ──────────────────────────────────────────────────────────
  GoogleMapController? _ctrl;
  Set<Marker> _markers = {};
  bool _mapReady = false;

  // ── Selection ────────────────────────────────────────────────────
  JobSeekerModel? _selected;

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
  void didUpdateWidget(covariant JobSeekerMapView old) {
    super.didUpdateWidget(old);
    if (old.seekers != widget.seekers && _mapReady) _buildMarkers();
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

  // ─────────────────────────────────────────────────────────────────
  //  Filtered list
  // ─────────────────────────────────────────────────────────────────
  List<JobSeekerModel> get _visible {
    return widget.seekers.where((s) {
      if (s.latitude == 0.0 && s.longitude == 0.0) return false;
      if (_filter.wilaya != null) {
        final wi = _filter.wilaya!.toLowerCase();
        if (!s.city.toLowerCase().contains(wi) &&
            !s.streetAddress.toLowerCase().contains(wi)) return false;
      }
      if (_filter.district != null) {
        final di = _filter.district!.toLowerCase();
        if (!s.city.toLowerCase().contains(di) &&
            !s.streetAddress.toLowerCase().contains(di)) return false;
      }
      if (_filter.jobTitleIds.isNotEmpty) {
        final match = _filter.jobTitleIds.any((id) {
          final opt = _optionById(id);
          return opt != null &&
              s.desiredPosition.toLowerCase() == opt.en.toLowerCase();
        });
        if (!match) return false;
      }
      if (_filter.jobTypes.isNotEmpty) {
        final jt = _field(s, 'jobType');
        if (jt != null && !_filter.jobTypes.contains(jt)) return false;
      }
      if (_filter.experienceLevel != null) {
        final exp = _field(s, 'experienceLevel');
        if (exp != null && exp != _filter.experienceLevel) return false;
      }
      return true;
    }).toList();
  }

  String? _field(JobSeekerModel s, String key) {
    try {
      return (s.toMap())[key] as String?;
    } catch (_) {
      return null;
    }
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

    for (final s in list) {
      final isSel = _selected?.userId == s.userId;
      final key = '${s.userId}_${isSel ? 'sel' : 'def'}';

      if (!_cache.containsKey(key)) {
        _cache[key] = await _paintGooglePin(
          label: s.desiredPosition,
          selected: isSel,
        );
      }

      result.add(
        Marker(
          markerId: MarkerId(s.userId),
          position: LatLng(s.latitude, s.longitude),
          icon: BitmapDescriptor.fromBytes(_cache[key]!),
          zIndex: isSel ? 10 : 1,
          anchor: const Offset(0.5, 0.72), // Points to the pin tip (pinH / h)
          onTap: () => _onPin(s),
        ),
      );
    }

    if (mounted) setState(() => _markers = result);
  }

  // ─────────────────────────────────────────────────────────────────
  //  Pin tap
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onPin(JobSeekerModel s) async {
    final same = _selected?.userId == s.userId;

    if (_selected != null) {
      _cache
        ..remove('${_selected!.userId}_sel')
        ..remove('${_selected!.userId}_def');
    }

    if (same) {
      setState(() => _selected = null);
      _safeAnimateSheet(0.30);
    } else {
      _cache
        ..remove('${s.userId}_sel')
        ..remove('${s.userId}_def');
      setState(() => _selected = s);
      _ctrl?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(s.latitude - 0.0004, s.longitude),
            zoom: 19.5,
            tilt: 45.0,
          ),
        ),
      );
      _safeAnimateSheet(0.52);
    }
    _buildMarkers();
  }

  // ─────────────────────────────────────────────────────────────────
  //  Dismiss selected
  // ─────────────────────────────────────────────────────────────────
  void _dismissSelected() {
    if (_selected == null) return;
    final id = _selected!.userId;
    setState(() => _selected = null);
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
        _selected = null;
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
                  _selected = null;
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
            return _BottomSheet(
              scrollController: scrollCtrl,
              selected: _selected,
              seekers: list,
              allOptions: widget.allOptions,
              locale: widget.locale,
              onClose: _dismissSelected,
              onSeekerTap: _onPin,
            );
          },
        ),

        // ── "No location" hint ───────────────────────────────────
        if (list.isEmpty && widget.seekers.isNotEmpty && _mapReady)
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
                          AppLocalizations.of(context)!.no_profiles_location_hint,
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
  final JobSeekerModel? selected;
  final List<JobSeekerModel> seekers;
  final List<JobOption> allOptions;
  final String locale;
  final VoidCallback onClose;
  final ValueChanged<JobSeekerModel> onSeekerTap;

  const _BottomSheet({
    required this.scrollController,
    required this.selected,
    required this.seekers,
    required this.allOptions,
    required this.locale,
    required this.onClose,
    required this.onSeekerTap,
  });

  @override
  Widget build(BuildContext context) {
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
                      if (selected != null) ...[
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3C28),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.profile,
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
                              AppLocalizations.of(context)!.profiles_on_map(seekers.length),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppLocalizations.of(context)!.tap_pin_or_scroll,
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
                            color: const Color(0xFF1A3C28),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${seekers.length}',
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
          if (selected != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: _SeekerDetailCard(seeker: selected!),
              ),
            )
          else if (seekers.isEmpty)
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
                    child: _SeekerListTile(
                      seeker: seekers[i],
                      onTap: () => onSeekerTap(seekers[i]),
                    ),
                  ),
                  childCount: seekers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SEEKER LIST TILE
// ═══════════════════════════════════════════════════════════════════
class _SeekerListTile extends StatelessWidget {
  final JobSeekerModel seeker;
  final VoidCallback onTap;
  const _SeekerListTile({required this.seeker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = seeker.isNameVisible
        ? '${seeker.firstName} ${seeker.lastName}'
        : AppLocalizations.of(context)!.anonymous_candidate;

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
            _SmallAvatar(seeker: seeker, name: name),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    seeker.desiredPosition,
                    style: const TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF2E7D52),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          seeker.city,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (seeker.skills.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5,
                      runSpacing: 4,
                      children: seeker.skills
                          .take(3)
                          .map(
                            (sk) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3C28)
                                    .withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                sk,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A3C28),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.greenCeladon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.greenCeladon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SEEKER DETAIL CARD
// ═══════════════════════════════════════════════════════════════════
class _SeekerDetailCard extends StatefulWidget {
  final JobSeekerModel seeker;
  const _SeekerDetailCard({required this.seeker});

  @override
  State<_SeekerDetailCard> createState() => _SeekerDetailCardState();
}

class _SeekerDetailCardState extends State<_SeekerDetailCard> {
  final _skillRepo = SkillMetaRepository();
  final _pvRepo = ProfileViewsRepository();

  StreamSubscription? _sub;
  Map<String, String> _statuses = {};
  bool _loadingMeta = true;
  bool _viewLoading = false;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(covariant _SeekerDetailCard old) {
    super.didUpdateWidget(old);
    if (old.seeker.userId != widget.seeker.userId) {
      _sub?.cancel();
      setState(() {
        _statuses = {};
        _loadingMeta = true;
      });
      _listen();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _listen() {
    _sub = _skillRepo.collection
        .where('jobSeekerId', isEqualTo: widget.seeker.userId)
        .snapshots()
        .listen((snap) {
      final metas = snap.docs
          .map((d) => SkillVerificationMeta.fromMap(
                d.data() as Map<String, dynamic>,
                d.id,
              ))
          .toList();
      final Map<String, String> m = {};
      for (final skill in widget.seeker.skills) {
        final meta = metas.firstWhere(
          (x) => x.skill == skill,
          orElse: () => SkillVerificationMeta(
            jobSeekerId: widget.seeker.userId,
            skill: skill,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        m[skill] = meta.status;
      }
      if (mounted) {
        setState(() {
          _statuses = m;
          _loadingMeta = false;
        });
      }
    });
  }

  int get _verified =>
      _statuses.values.where((v) => v.toLowerCase() == 'verified').length;

  @override
  Widget build(BuildContext context) {
    final s = widget.seeker;
    final name = s.isNameVisible
        ? '${s.firstName} ${s.lastName}'
        : AppLocalizations.of(context)!.anonymous_candidate;

    final sorted = _statuses.entries.toList()
      ..sort((a, b) {
        final av = a.value.toLowerCase() == 'verified' ? 0 : 1;
        final bv = b.value.toLowerCase() == 'verified' ? 0 : 1;
        return av.compareTo(bv);
      });
    final show = sorted.take(6).toList();
    final extra = sorted.length - show.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile hero
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.greenCeladon.withOpacity(0.05),
                AppColors.greenCeladon.withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.greenCeladon.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(seeker: s, name: name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111111),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_verified > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded,
                                    size: 12,
                                    color: Colors.green.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '$_verified verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.desiredPosition,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D52),
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
                            s.city,
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

        // Skills
        Text(
          AppLocalizations.of(context)!.skills,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 8),

        if (_loadingMeta)
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          )
        else if (show.isEmpty)
          Text(
            AppLocalizations.of(context)!.no_skills_listed,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...show.map((e) {
                final v = e.value.toLowerCase() == 'verified';
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        v ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: v
                        ? Border.all(
                            color: Colors.green.shade200, width: 0.8)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: v
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      if (v) ...[
                        const SizedBox(width: 3),
                        Icon(Icons.verified_rounded,
                            size: 11, color: Colors.green.shade500),
                      ],
                    ],
                  ),
                );
              }),
              if (extra > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.plus_more_count(extra),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3C28),
                    ),
                  ),
                ),
            ],
          ),

        // Experience
        if (s.experienceDetails?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.experience,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            s.experienceDetails!,
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade600, height: 1.5),
          ),
        ],

        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final auth = context.read<AuthProvider>();
                  if (auth.user == null) return;
                  final id = await ChatService().getOrCreateChat(
                    auth.user!.userId,
                    s.userId,
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: id,
                        otherUserId: s.userId,
                        personName: name,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded,
                    size: 15),
                label: Text(AppLocalizations.of(context)!.chat),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  foregroundColor: const Color(0xFF111111),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _viewLoading
                    ? null
                    : () async {
                        final auth = context.read<AuthProvider>();
                        if (auth.user == null) return;
                        setState(() => _viewLoading = true);
                        try {
                          await _pvRepo.saveUniqueDailyView(
                            userId: s.userId,
                            viewerId: auth.user!.userId,
                          );
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobSeekerDetailScreen(seeker: s),
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _viewLoading = false);
                          }
                        }
                      },
                icon: _viewLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_outline_rounded, size: 15),
                label: Text(AppLocalizations.of(context)!.view_profile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenCeladon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SMALL AVATAR (list tile)
// ═══════════════════════════════════════════════════════════════════
class _SmallAvatar extends StatelessWidget {
  final JobSeekerModel seeker;
  final String name;
  const _SmallAvatar({required this.seeker, required this.name});

  String get _initials {
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
          child: seeker.logoUrl?.isNotEmpty == true
              ? Image.network(
                  seeker.logoUrl!,
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
  final JobSeekerModel seeker;
  final String name;
  const _Avatar({required this.seeker, required this.name});

  String get _initials {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : name.isNotEmpty
            ? name[0].toUpperCase()
            : '?';
  }

  @override
  Widget build(BuildContext context) => Container(
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
          child: seeker.logoUrl?.isNotEmpty == true
              ? Image.network(
                  seeker.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _InitialsText(_initials, size: 20),
                )
              : _InitialsText(_initials, size: 20),
        ),
      );
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
                Icon(Icons.person_search_rounded,
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
                                AppLocalizations.of(context)!.filter_profiles_hint,
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
                  AppLocalizations.of(context)!.filter_profiles_hint.replaceAll('…', ''),
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
                _Sec(AppLocalizations.of(context)!.job_type, Icons.schedule_rounded),
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
                        backgroundColor: AppColors.greenCeladon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.show_results,
                        style: TextStyle(
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
                ? AppColors.greenCeladon
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: selected
                  ? AppColors.greenCeladon
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