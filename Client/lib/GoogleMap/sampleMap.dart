// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapSample extends StatefulWidget {
//   const MapSample({super.key});

//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   static const CameraPosition _kLake = CameraPosition(
//     bearing: 192.8334901395799,
//     target: LatLng(37.43296265331129, -122.08832357078792),
//     tilt: 59.440717697143555,
//     zoom: 19.151926040649414,
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: _kGooglePlex,
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToTheLake,
//         label: const Text('To the lake!'),
//         icon: const Icon(Icons.directions_boat),
//       ),
//     );
//   }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const String kGoogleApiKey = 'AIzaSyAnsnuY_5uhGPo1HpUBNvfV9up_sFrV04o';
const Color kAccent     = Color(0xFFFFD600);
const Color kDark       = Color(0xFF0D0D14);
const Color kCard       = Color(0xFF1A1A26);
const Color kCardBorder = Color(0xFF2E2E42);
const Color kText       = Color(0xFFF0F0F8);
const Color kSubText    = Color(0xFF8888A8);

// ── Place model ───────────────────────────────────────────────
class _Place {
  final String placeId, mainText, secondaryText, fullText;
  _Place({required this.placeId, required this.mainText,
          required this.secondaryText, required this.fullText});
  factory _Place.fromJson(Map<String, dynamic> j) {
    final sf = j['structured_formatting'] ?? {};
    return _Place(
      placeId:       j['place_id']    ?? '',
      mainText:      sf['main_text']  ?? '',
      secondaryText: sf['secondary_text'] ?? '',
      fullText:      j['description'] ?? '',
    );
  }
}

// ── HTTP service ──────────────────────────────────────────────
class _Api {
  static Future<List<_Place>> suggest(String q) async {
    if (q.trim().isEmpty) return [];
    final r = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(q)}&key=$kGoogleApiKey'));
    if (r.statusCode != 200) return [];
    return ((jsonDecode(r.body)['predictions'] as List?) ?? [])
        .map((p) => _Place.fromJson(p)).toList();
  }

  static Future<LatLng?> latLng(String placeId) async {
    final r = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId&fields=geometry&key=$kGoogleApiKey'));
    if (r.statusCode != 200) return null;
    final loc = jsonDecode(r.body)['result']?['geometry']?['location'];
    if (loc == null) return null;
    return LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
  }
}

// ─────────────────────────────────────────────────────────────
//  MapSample
// ─────────────────────────────────────────────────────────────
class MapSample extends StatefulWidget {
  const MapSample({super.key});
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample>
    with SingleTickerProviderStateMixin {

  final _mapCtrl = Completer<GoogleMapController>();
  late AnimationController _panelAnim;
  late Animation<double>   _panelSlide;

  LatLng  _pickupLL   = const LatLng(31.5204, 74.3587);
  LatLng? _destLL;
  String  _pickupAddr = 'Current Location';
  String  _destAddr   = '';
  bool    _destSet    = false;

  final Set<Marker>   _markers   = {};
  final Set<Polyline> _polylines = {};

  static const String _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#0d0d14"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1a1a2e"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},
    {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},
    {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#2f3948"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},
    {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _panelAnim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _panelSlide = CurvedAnimation(parent: _panelAnim, curve: Curves.easeOutCubic);
    _setMarker(isPickup: true, pos: _pickupLL);
    _panelAnim.forward();
  }

  @override
  void dispose() { _panelAnim.dispose(); super.dispose(); }

  // ── markers & route ───────────────────────────────────────
  void _setMarker({required bool isPickup, required LatLng pos}) {
    final id = isPickup ? 'pickup' : 'dest';
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == id);
      _markers.add(Marker(
        markerId: MarkerId(id),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isPickup ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: isPickup ? 'Pickup' : 'Destination'),
      ));
      if (!isPickup && _destLL != null) {
        _polylines
          ..clear()
          ..add(Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLL, pos],
            color: kAccent, width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ));
      }
    });
  }

  // ── camera ────────────────────────────────────────────────
  Future<void> _flyTo(LatLng t, {bool is3D = false}) async {
    (await _mapCtrl.future).animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: t, zoom: is3D ? 18.5 : 15,
        tilt: is3D ? 55 : 0, bearing: is3D ? 30 : 0,
      )));
  }

  Future<void> _fitRoute() async {
    if (_destLL == null) return;
    final sw = LatLng(
      _pickupLL.latitude  < _destLL!.latitude  ? _pickupLL.latitude  : _destLL!.latitude,
      _pickupLL.longitude < _destLL!.longitude ? _pickupLL.longitude : _destLL!.longitude,
    );
    final ne = LatLng(
      _pickupLL.latitude  > _destLL!.latitude  ? _pickupLL.latitude  : _destLL!.latitude,
      _pickupLL.longitude > _destLL!.longitude ? _pickupLL.longitude : _destLL!.longitude,
    );
    (await _mapCtrl.future).animateCamera(
      CameraUpdate.newLatLngBounds(LatLngBounds(southwest: sw, northeast: ne), 100));
  }

  // ── open search ───────────────────────────────────────────
  void _openSearch({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => _SearchSheet(
        isPickup: isPickup,
        onSelected: (place, latlng) async {
          if (isPickup) {
            setState(() { _pickupLL = latlng; _pickupAddr = place.fullText; });
            _setMarker(isPickup: true, pos: latlng);
            await _flyTo(latlng, is3D: true);
          } else {
            setState(() { _destLL = latlng; _destAddr = place.fullText; _destSet = true; });
            _setMarker(isPickup: false, pos: latlng);
            await Future.delayed(const Duration(milliseconds: 300));
            await _flyTo(latlng, is3D: true);
          }
        },
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDark,
      body: Stack(children: [
        // MAP
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(target: _pickupLL, zoom: 15),
          markers: _markers, polylines: _polylines,
          myLocationEnabled: true, myLocationButtonEnabled: false,
          zoomControlsEnabled: false, compassEnabled: false,
          onMapCreated: (c) async {
            _mapCtrl.complete(c);
            await c.setMapStyle(_mapStyle);
          },
        ),
        // top fade
        Positioned(top: 0, left: 0, right: 0, height: 180,
          child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [kDark.withOpacity(.9), kDark.withOpacity(0)]),
          )))),
        // bottom panel
        Positioned(bottom: 0, left: 0, right: 0,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0,1), end: Offset.zero).animate(_panelSlide),
            child: _panel(),
          )),
        // top bar
        SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(children: [
            _glass(Icons.arrow_back_ios_new_rounded, () => Navigator.maybePop(context)),
            const Spacer(),
            _glass(Icons.my_location_rounded, () => _flyTo(_pickupLL, is3D: true)),
          ]),
        )),
      ]),
    );
  }

  // ── bottom panel ──────────────────────────────────────────
  Widget _panel() => ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        decoration: BoxDecoration(
          color: kCard.withOpacity(.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: const Border(top: BorderSide(color: kCardBorder)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: kCardBorder, borderRadius: BorderRadius.circular(2)))),
          Text(_destSet ? 'Your Ride' : 'Where to?',
            style: const TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.4)),
          const SizedBox(height: 16),
          _row(Icons.circle, kAccent, 'Pickup location', _pickupAddr, () => _openSearch(isPickup: true)),
          Padding(padding: const EdgeInsets.only(left: 19),
            child: Column(children: List.generate(3, (_) => Container(
              width: 2, height: 6, margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(color: kCardBorder, borderRadius: BorderRadius.circular(1)),
            )))),
          _row(Icons.location_on, const Color(0xFFFF4B6E), 'Enter destination',
            _destAddr.isEmpty ? null : _destAddr, () => _openSearch(isPickup: false)),
          const SizedBox(height: 24),
          if (_destSet) _confirmBtn() else _recents(),
        ]),
      ),
    ),
  );

  Widget _row(IconData icon, Color color, String hint, String? text, VoidCallback onTap) =>
    GestureDetector(onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(color: kDark.withOpacity(.6),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: kCardBorder)),
        child: Row(children: [
          Icon(icon, color: color, size: 18), const SizedBox(width: 12),
          Expanded(child: Text(text ?? hint,
            style: TextStyle(color: text != null ? kText : kSubText, fontSize: 15,
              fontWeight: text != null ? FontWeight.w500 : FontWeight.w400),
            overflow: TextOverflow.ellipsis)),
          if (text != null) const Icon(Icons.chevron_right_rounded, color: kSubText, size: 18),
        ]),
      ));

  Widget _confirmBtn() => SizedBox(width: double.infinity, height: 56,
    child: ElevatedButton(onPressed: _fitRoute,
      style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: kDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.route_rounded, size: 20), SizedBox(width: 10),
        Text('View Route', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ])));

  Widget _recents() {
    final list = [
      ('Home', '123 Main Street',      Icons.home_rounded),
      ('Work', 'DHA Phase 5, Lahore',  Icons.work_rounded),
      ('Mall', 'Emporium Mall, Lahore',Icons.shopping_bag_rounded),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('RECENT', style: TextStyle(color: kSubText, fontSize: 11,
        fontWeight: FontWeight.w600, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      ...list.map((p) => Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: kDark, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCardBorder)),
            child: Icon(p.$3, color: kAccent, size: 18)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.$1, style: const TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(p.$2, style: const TextStyle(color: kSubText, fontSize: 12)),
          ]),
        ]))),
    ]);
  }

  Widget _glass(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap,
    child: ClipRRect(borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(width: 44, height: 44,
          decoration: BoxDecoration(color: kCard.withOpacity(.85),
            borderRadius: BorderRadius.circular(14), border: Border.all(color: kCardBorder)),
          child: Icon(icon, color: kText, size: 18)))));
}

// ─────────────────────────────────────────────────────────────
//  Search Sheet — NO google_places_flutter, pure HTTP
// ─────────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final bool isPickup;
  final void Function(_Place place, LatLng latlng) onSelected;
  const _SearchSheet({required this.isPickup, required this.onSelected});
  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _ctrl = TextEditingController();
  List<_Place> _results = [];
  bool _busy = false;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); _ctrl.dispose(); super.dispose(); }

  void _onChange(String v) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      setState(() => _busy = true);
      final r = await _Api.suggest(v);
      if (!mounted) return;
      setState(() { _results = r; _busy = false; });
    });
  }

  Future<void> _pick(_Place p) async {
    // Pop SYNCHRONOUSLY before any await — this is the crash fix
    Navigator.of(context).pop();
    final ll = await _Api.latLng(p.placeId);
    if (ll != null) widget.onSelected(p, ll);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: MediaQuery.of(context).size.height * .85,
          decoration: const BoxDecoration(color: kCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: kCardBorder, borderRadius: BorderRadius.circular(2))),
            Text(widget.isPickup ? 'Set Pickup' : 'Set Destination',
              style: const TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            // ── plain TextField — no buggy package ──────────
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onChange,
              style: const TextStyle(color: kText, fontSize: 15),
              decoration: InputDecoration(
                hintText: widget.isPickup ? 'Search pickup…' : 'Search destination…',
                hintStyle: const TextStyle(color: kSubText, fontSize: 14),
                filled: true, fillColor: kDark,
                prefixIcon: Icon(
                  widget.isPickup ? Icons.circle : Icons.location_on_rounded,
                  color: widget.isPickup ? kAccent : const Color(0xFFFF4B6E), size: 18),
                suffixIcon: _busy
                  ? const Padding(padding: EdgeInsets.all(12),
                      child: SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: kAccent, strokeWidth: 2)))
                  : null,
                border:        OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kCardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kCardBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kAccent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(color: kCardBorder, height: 1),
                itemBuilder: (_, i) {
                  final p = _results[i];
                  return InkWell(
                    onTap: () => _pick(p),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Row(children: [
                        Container(width: 36, height: 36,
                          decoration: BoxDecoration(color: kDark,
                            borderRadius: BorderRadius.circular(10), border: Border.all(color: kCardBorder)),
                          child: const Icon(Icons.location_on_outlined, color: kAccent, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.mainText, style: const TextStyle(color: kText, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(p.secondaryText, style: const TextStyle(color: kSubText, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ])),
                      ])),
                  );
                },
              ),
            ),
          ]),
        )),
    );
  }
}