import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/Recruiterenum.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const String _kApiKey = 'AIzaSyAnsnuY_5uhGPo1HpUBNvfV9up_sFrV04o';

Color get _green => AppColors.greenCeladon;
Color get _greenLight => AppColors.greenCeladon;
const Color _bg = Color(0xFFF5F9F5);
const Color _card = Color(0xFFFFFFFF);
Color get _border => AppColors.greenCeladon;
const Color _textDark = Color(0xFF1B2D1B);
Color get _textSub => AppColors.greenCeladon;

// ─────────────────────────────────────────────────────────────
//  PLACE model
// ─────────────────────────────────────────────────────────────
class _Place {
  final String placeId, mainText, secondaryText, fullText;
  _Place({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });
  factory _Place.fromJson(Map<String, dynamic> j) {
    final sf = j['structured_formatting'] ?? {};
    return _Place(
      placeId: j['place_id'] ?? '',
      mainText: sf['main_text'] ?? '',
      secondaryText: sf['secondary_text'] ?? '',
      fullText: j['description'] ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HTTP helpers
// ─────────────────────────────────────────────────────────────
class _Api {
  static Future<List<_Place>> suggest(String q) async {
    if (q.trim().isEmpty) return [];
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final r = await http
            .get(
              Uri.parse(
                'https://maps.googleapis.com/maps/api/place/autocomplete/json'
                '?input=${Uri.encodeComponent(q)}&key=$_kApiKey',
              ),
            )
            .timeout(const Duration(seconds: 8)); // add timeout

        if (r.statusCode != 200) return [];
        return ((jsonDecode(r.body)['predictions'] as List?) ?? [])
            .map((p) => _Place.fromJson(p))
            .toList();
      } on TimeoutException {
        // timed out — retry
        continue;
      } catch (e) {
        // HandshakeException / ClientException — wait then retry
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        return []; // give up silently after 3 attempts
      }
    }
    return [];
  }

  static Future<LatLng?> latLng(String placeId) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              'https://maps.googleapis.com/maps/api/place/details/json'
              '?place_id=$placeId&fields=geometry&key=$_kApiKey',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      final loc = jsonDecode(r.body)['result']?['geometry']?['location'];
      if (loc == null) return null;
      return LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> reverseGeocode(LatLng ll) async {
    try {
      final r = await http
          .get(
            Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json'
              '?latlng=${ll.latitude},${ll.longitude}&key=$_kApiKey',
            ),
          )
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return '${ll.latitude}, ${ll.longitude}';
      final results = jsonDecode(r.body)['results'] as List?;
      return results?.isNotEmpty == true
          ? results![0]['formatted_address'] as String
          : '${ll.latitude}, ${ll.longitude}';
    } catch (_) {
      return '${ll.latitude}, ${ll.longitude}';
    }
  }
}
// ─────────────────────────────────────────────────────────────
//  RECRUITER LOCATION PICKER
// ─────────────────────────────────────────────────────────────
class RecruiterLocationPicker extends StatefulWidget {
  final Recruiter recruiter;
  const RecruiterLocationPicker({super.key, required this.recruiter});
  @override
  State<RecruiterLocationPicker> createState() =>
      _RecruiterLocationPickerState();
}

class _RecruiterLocationPickerState extends State<RecruiterLocationPicker>
    with SingleTickerProviderStateMixin {
  final _repo = RecruiterRepository();
  final _mapKey = GlobalKey();

  GoogleMapController? _mapController;
  // ── Completer so we can await the controller being ready ──
  final _controllerReady = Completer<void>();

  late AnimationController _panelAnim;
  late Animation<double> _panelSlide;

  static const LatLng _defaultLL = LatLng(36.7372, 3.0869);

  late LatLng _pickedLL;
  late String _pickedAddress;
  bool _hasPin = false;
  bool _saving = false;
  bool _loadingAddr = false;
  final Set<Marker> _markers = {};

  static const String _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#e8f5e9"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#2e7d32"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#f5f9f5"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#388e3c"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#a5d6a7"}]},
    {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#81c784"}]},
    {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#1b5e20"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b3e5fc"}]},
    {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#f1f8e9"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _panelSlide = CurvedAnimation(
      parent: _panelAnim,
      curve: Curves.easeOutCubic,
    );

    if (widget.recruiter.latitude != 0) {
      _pickedLL = LatLng(widget.recruiter.latitude, widget.recruiter.longitude);
      _pickedAddress = widget.recruiter.streetAddress;
      _hasPin = true;
      _setMarker(_pickedLL);
    } else {
      _pickedLL = _defaultLL;
      _pickedAddress = '';
    }
    _panelAnim.forward();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    _panelAnim.dispose();
    super.dispose();
  }

  // ── Wait for controller, then animate ──────────────────────
  Future<void> _flyTo(LatLng t, {bool is3D = false}) async {
    // Wait until onMapCreated has fired
    await _controllerReady.future;
    if (_mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: t,
          zoom: is3D ? 17.5 : 14.0,
          tilt: is3D ? 50.0 : 0.0,
          bearing: is3D ? 15.0 : 0.0,
        ),
      ),
    );
  }

  void _setMarker(LatLng pos) {
    if (!mounted) return;
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('recruiter'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'Pharmacy Location'),
        ),
      );
    });
  }

  Future<void> _onMapTap(LatLng pos) async {
    if (!mounted) return;
    setState(() {
      _pickedLL = pos;
      _hasPin = true;
      _loadingAddr = true;
    });
    _setMarker(pos);
    // fly first so the animation plays while geocoding runs in background
    _flyTo(pos, is3D: true);
    final addr = await _Api.reverseGeocode(pos);
    if (mounted)
      setState(() {
        _pickedAddress = addr;
        _loadingAddr = false;
      });
  }

  Future<void> _onPlaceSelected(_Place place, LatLng ll) async {
    if (!mounted) return;
    setState(() {
      _pickedLL = ll;
      _pickedAddress = place.fullText;
      _hasPin = true;
      _loadingAddr = false;
    });
    _setMarker(ll);
    // fly after state is set — controller is guaranteed ready here
    await _flyTo(ll, is3D: true);
  }

  Future<void> _save() async {
    if (!_hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a location first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final updated = Recruiter(
        userId: widget.recruiter.userId,
        pharmacyName: widget.recruiter.pharmacyName,
        pharmacistFirstName: widget.recruiter.pharmacistFirstName,
        pharmacistLastName: widget.recruiter.pharmacistLastName,
        province: widget.recruiter.province,
        city: widget.recruiter.city,
        streetAddress: _pickedAddress,
        latitude: _pickedLL.latitude,
        longitude: _pickedLL.longitude,
        createdAt: widget.recruiter.createdAt,
        isActive: widget.recruiter.isActive,
        profileStatus: widget.recruiter.profileStatus,
        licenseStatus: widget.recruiter.licenseStatus,
        licenseExpiresAt: widget.recruiter.licenseExpiresAt,
        docId: widget.recruiter.docId,
        logoUrl: widget.recruiter.logoUrl,
      );
      await _repo.update(widget.recruiter.docId!, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pharmacy location saved'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openSearch() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _SearchSheet(
      icon: Icons.work_rounded,
      title: 'Search Pharmacy Location',
      onSelected: _onPlaceSelected,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return _MapScaffold(
      mapKey: _mapKey,
      title: 'Pharmacy Location',
      icon: Icons.work_rounded,
      mapStyle: _mapStyle,
      markers: _markers,
      panelSlide: _panelSlide,
      hasPin: _hasPin,
      saving: _saving,
      loadingAddr: _loadingAddr,
      pickedLL: _pickedLL,
      pickedAddress: _pickedAddress,
      initialLatLng: widget.recruiter.latitude != 0
          ? LatLng(widget.recruiter.latitude, widget.recruiter.longitude)
          : null,
      onMapCreated: (controller) async {
        _mapController = controller;
        // ── Mark controller as ready so _flyTo can proceed ──
        if (!_controllerReady.isCompleted) _controllerReady.complete();
        await controller.setMapStyle(_mapStyle);
        // Fly to existing location on open
        if (widget.recruiter.latitude != 0) {
          await _flyTo(
            LatLng(widget.recruiter.latitude, widget.recruiter.longitude),
            is3D: true,
          );
        }
      },
      onMapTap: _onMapTap,
      onBack: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RecruiterAccountScreen(
                    mode: AccountFormMode.edit),
              ),
            ),
      onMyLocation: () => _flyTo(_pickedLL, is3D: true),
      onSearch: _openSearch,
      onSave: _save,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  JOB SEEKER LOCATION PICKER
// ─────────────────────────────────────────────────────────────
class JobSeekerLocationPicker extends StatefulWidget {
  final JobSeekerModel jobSeeker;
  const JobSeekerLocationPicker({super.key, required this.jobSeeker});
  @override
  State<JobSeekerLocationPicker> createState() =>
      _JobSeekerLocationPickerState();
}

class _JobSeekerLocationPickerState extends State<JobSeekerLocationPicker>
    with SingleTickerProviderStateMixin {
  final _repo = JobSeekerRepository();
  final _mapKey = GlobalKey();

  GoogleMapController? _mapController;
  final _controllerReady = Completer<void>();

  late AnimationController _panelAnim;
  late Animation<double> _panelSlide;

  static const LatLng _defaultLL = LatLng(36.7372, 3.0869);

  late LatLng _pickedLL;
  late String _pickedAddress;
  bool _hasPin = false;
  bool _saving = false;
  bool _loadingAddr = false;
  final Set<Marker> _markers = {};

  static const String _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#e8f5e9"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#2e7d32"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#f5f9f5"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#388e3c"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#a5d6a7"}]},
    {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#81c784"}]},
    {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#1b5e20"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b3e5fc"}]},
    {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#f1f8e9"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _panelSlide = CurvedAnimation(
      parent: _panelAnim,
      curve: Curves.easeOutCubic,
    );

    if (widget.jobSeeker.latitude != 0) {
      _pickedLL = LatLng(widget.jobSeeker.latitude, widget.jobSeeker.longitude);
      _pickedAddress = widget.jobSeeker.streetAddress;
      _hasPin = true;
      _setMarker(_pickedLL);
    } else {
      _pickedLL = _defaultLL;
      _pickedAddress = '';
    }
    _panelAnim.forward();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    _panelAnim.dispose();
    super.dispose();
  }

  Future<void> _flyTo(LatLng t, {bool is3D = false}) async {
    await _controllerReady.future;
    if (_mapController == null) return;
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: t,
          zoom: is3D ? 17.5 : 14.0,
          tilt: is3D ? 50.0 : 0.0,
          bearing: is3D ? 15.0 : 0.0,
        ),
      ),
    );
  }

  void _setMarker(LatLng pos) {
    if (!mounted) return;
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('jobseeker'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    });
  }

  Future<void> _onMapTap(LatLng pos) async {
    if (!mounted) return;
    setState(() {
      _pickedLL = pos;
      _hasPin = true;
      _loadingAddr = true;
    });
    _setMarker(pos);
    _flyTo(pos, is3D: true); // fire and continue — geocode runs in parallel
    final addr = await _Api.reverseGeocode(pos);
    if (mounted)
      setState(() {
        _pickedAddress = addr;
        _loadingAddr = false;
      });
  }

  Future<void> _onPlaceSelected(_Place place, LatLng ll) async {
    if (!mounted) return;
    setState(() {
      _pickedLL = ll;
      _pickedAddress = place.fullText;
      _hasPin = true;
      _loadingAddr = false;
    });
    _setMarker(ll);
    await _flyTo(ll, is3D: true);
  }

  Future<void> _save() async {
    if (!_hasPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a location first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      final updated = JobSeekerModel(
        userId: widget.jobSeeker.userId,
        firstName: widget.jobSeeker.firstName,
        lastName: widget.jobSeeker.lastName,
        isNameVisible: widget.jobSeeker.isNameVisible,
        email: widget.jobSeeker.email,
        province: widget.jobSeeker.province,
        city: widget.jobSeeker.city,
        streetAddress: _pickedAddress,
        latitude: _pickedLL.latitude,
        longitude: _pickedLL.longitude,
        phoneNumber: widget.jobSeeker.phoneNumber,
        desiredPosition: widget.jobSeeker.desiredPosition,
        skills: widget.jobSeeker.skills,
        educationBackground: widget.jobSeeker.educationBackground,
        experienceDetails: widget.jobSeeker.experienceDetails,
        createdAt: widget.jobSeeker.createdAt,
        isActive: widget.jobSeeker.isActive,
        docId: widget.jobSeeker.docId,
        logoUrl: widget.jobSeeker.logoUrl,
      );
      await _repo.update(widget.jobSeeker.docId!, updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Your location saved'),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openSearch() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (_) => _SearchSheet(
      icon: Icons.person_pin_circle_rounded,
      title: 'Search Your Location',
      onSelected: _onPlaceSelected,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return _MapScaffold(
      mapKey: _mapKey,
      title: 'Your Location',
      icon: Icons.person_pin_circle_rounded,
      mapStyle: _mapStyle,
      markers: _markers,
      panelSlide: _panelSlide,
      hasPin: _hasPin,
      saving: _saving,
      loadingAddr: _loadingAddr,
      pickedLL: _pickedLL,
      pickedAddress: _pickedAddress,
      initialLatLng: widget.jobSeeker.latitude != 0
          ? LatLng(widget.jobSeeker.latitude, widget.jobSeeker.longitude)
          : null,
      onMapCreated: (controller) async {
        _mapController = controller;
        if (!_controllerReady.isCompleted) _controllerReady.complete();
        await controller.setMapStyle(_mapStyle);
        if (widget.jobSeeker.latitude != 0) {
          await _flyTo(
            LatLng(widget.jobSeeker.latitude, widget.jobSeeker.longitude),
            is3D: true,
          );
        }
      },
      onMapTap: _onMapTap,
      onBack: () => Navigator.maybePop(context),
      onMyLocation: () => _flyTo(_pickedLL, is3D: true),
      onSearch: _openSearch,
      onSave: _save,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SHARED MAP SCAFFOLD
// ─────────────────────────────────────────────────────────────
class _MapScaffold extends StatelessWidget {
  final Key mapKey;
  final String title;
  final IconData icon;
  final String mapStyle;
  final Set<Marker> markers;
  final Animation<double> panelSlide;
  final bool hasPin, saving, loadingAddr;
  final LatLng pickedLL;
  final String pickedAddress;
  final LatLng? initialLatLng;
  final void Function(GoogleMapController) onMapCreated;
  final Future<void> Function(LatLng) onMapTap;
  final VoidCallback onBack, onMyLocation, onSearch, onSave;

  const _MapScaffold({
    required this.mapKey,
    required this.title,
    required this.icon,
    required this.mapStyle,
    required this.markers,
    required this.panelSlide,
    required this.hasPin,
    required this.saving,
    required this.loadingAddr,
    required this.pickedLL,
    required this.pickedAddress,
    required this.initialLatLng,
    required this.onMapCreated,
    required this.onMapTap,
    required this.onBack,
    required this.onMyLocation,
    required this.onSearch,
    required this.onSave,
  });

  static const LatLng _defaultLL = LatLng(36.7372, 3.0869);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          GoogleMap(
            key: mapKey,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              // ── Start zoomed in if we already have a location ──
              target: initialLatLng ?? _defaultLL,
              zoom: initialLatLng != null ? 17.5 : 12.0,
              tilt: initialLatLng != null ? 50.0 : 0.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            onMapCreated: onMapCreated,
            onTap: onMapTap,
          ),

          // top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_bg.withOpacity(.95), _bg.withOpacity(0)],
                  ),
                ),
              ),
            ),
          ),

          // top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _glassBtn(Icons.arrow_back_ios_new_rounded, onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onSearch,
                      child: _searchBarWidget(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _glassBtn(Icons.my_location_rounded, onMyLocation),
                ],
              ),
            ),
          ),

          // hint
          if (!hasPin)
            Center(
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tap map to drop pin or search above',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(panelSlide),
              child: _bottomPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBarWidget() => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _card.withOpacity(.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: _green, size: 20),
            const SizedBox(width: 10),
            Text(
              'Search location…',
              style: TextStyle(color: _textSub, fontSize: 14),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _bottomPanel(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _card.withOpacity(.97),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: _border, width: 1.5)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_green, _greenLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hasPin ? 'Location selected' : 'No location selected',
                      style: TextStyle(
                        color: hasPin ? _green : _textSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: hasPin ? _addressCard() : _emptyState(),
            ),
            const SizedBox(height: 20),
            _saveButton(),
          ],
        ),
      ),
    ),
  );

  Widget _addressCard() => Container(
    key: const ValueKey('addr'),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _green.withOpacity(.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _green.withOpacity(.25)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_rounded, color: _green, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: loadingAddr
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: _green,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fetching address…',
                      style: TextStyle(color: _textSub, fontSize: 13),
                    ),
                  ],
                )
              : Text(
                  pickedAddress.isEmpty
                      ? '${pickedLL.latitude.toStringAsFixed(5)}, '
                            '${pickedLL.longitude.toStringAsFixed(5)}'
                      : pickedAddress,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _green.withOpacity(.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Change',
              style: TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _emptyState() => Container(
    key: const ValueKey('empty'),
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.location_searching_rounded, color: _textSub, size: 20),
        const SizedBox(width: 10),
        Text(
          'Tap anywhere on the map to select',
          style: TextStyle(color: _textSub, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _saveButton() => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: (!hasPin || saving) ? null : onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.zero,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: hasPin
              ? LinearGradient(
                  colors: [_green, _greenLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasPin
              ? [
                  BoxShadow(
                    color: _green.withOpacity(.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: hasPin ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confirm Location',
                      style: TextStyle(
                        color: hasPin ? Colors.white : Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );

  Widget _glassBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _card.withOpacity(.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: _green, size: 20),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
//  SEARCH SHEET
// ─────────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final IconData icon;
  final String title;
  final void Function(_Place, LatLng) onSelected;
  const _SearchSheet({
    required this.icon,
    required this.title,
    required this.onSelected,
  });
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  List<_Place> _results = [];
  bool _busy = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChange(String v) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      setState(() => _busy = true);
      final r = await _Api.suggest(v);
      if (!mounted) return;
      setState(() {
        _results = r;
        _busy = false;
      });
    });
  }

  Future<void> _pick(_Place p) async {
    Navigator.of(context).pop(); // sync pop BEFORE await
    final ll = await _Api.latLng(p.placeId);
    if (ll != null) widget.onSelected(p, ll);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: MediaQuery.of(context).size.height * .88,
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_green, _greenLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onChange,
              style: TextStyle(color: _textDark, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type an address or place name…',
                hintStyle: TextStyle(color: _textSub, fontSize: 14),
                filled: true,
                fillColor: _bg,
                prefixIcon: Icon(Icons.search_rounded, color: _green, size: 20),
                suffixIcon: _busy
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: _green,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : (_ctrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: _textSub,
                                size: 18,
                              ),
                              onPressed: () {
                                _ctrl.clear();
                                setState(() => _results = []);
                              },
                            )
                          : null),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _green, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty && !_busy
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: _border,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start typing to search',
                            style: TextStyle(color: _textSub, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: _border, height: 1),
                      itemBuilder: (_, i) {
                        final p = _results[i];
                        return InkWell(
                          onTap: () => _pick(p),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _green.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _green.withOpacity(.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: _green,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.mainText,
                                        style: TextStyle(
                                          color: _textDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        p.secondaryText,
                                        style: TextStyle(
                                          color: _textSub,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
}
