import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

const _key = 'AIzaSyAnsnuY_5uhGPo1HpUBNvfV9up_sFrV04o';

List<LatLng> _decode(String enc) {
  final pts = <LatLng>[];
  int i = 0, lat = 0, lng = 0;
  while (i < enc.length) {
    int b, s = 0, r = 0;
    do {
      b = enc.codeUnitAt(i++) - 63;
      r |= (b & 0x1f) << s;
      s += 5;
    } while (b >= 0x20);
    lat += (r & 1) != 0 ? ~(r >> 1) : r >> 1;
    s = r = 0;
    do {
      b = enc.codeUnitAt(i++) - 63;
      r |= (b & 0x1f) << s;
      s += 5;
    } while (b >= 0x20);
    lng += (r & 1) != 0 ? ~(r >> 1) : r >> 1;
    pts.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return pts;
}

double _km(LatLng a, LatLng b) {
  const R = 6371.0;
  final dLat = (b.latitude - a.latitude) * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(a.latitude * math.pi / 180) *
          math.cos(b.latitude * math.pi / 180) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return R * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
}

// ─────────────────────────────────────────────────────────────
//  URL LAUNCHERS
// ─────────────────────────────────────────────────────────────

/// Opens the correct maps app based on platform:
///   Android → Google Maps (geo: intent or directions web URL)
///   iOS     → Apple Maps (maps.apple.com — works on Simulator + real device)
///
/// Falls back to a Google Maps web URL on both platforms if needed.
Future<void> _openInMaps({
  required LatLng dest,
  LatLng? origin, // null → maps app uses device current location
}) async {
  // ── ANDROID ──────────────────────────────────────────────
  if (Platform.isAndroid) {
    if (origin != null) {
      // Directions URL — Android opens this directly in the Google Maps app
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.latitude},${origin.longitude}'
        '&destination=${dest.latitude},${dest.longitude}'
        '&travelmode=driving',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // geo: intent pins the destination in Google Maps
      final geo = Uri.parse(
          'geo:${dest.latitude},${dest.longitude}'
          '?q=${dest.latitude},${dest.longitude}');
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo);
      } else {
        final web = Uri.parse(
          'https://www.google.com/maps/dir/?api=1'
          '&destination=${dest.latitude},${dest.longitude}'
          '&travelmode=driving',
        );
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    }
    return;
  }

  // ── iOS ──────────────────────────────────────────────────
  if (Platform.isIOS) {
    // maps.apple.com always works on real device AND Simulator
    final originPart =
        origin != null ? '&saddr=${origin.latitude},${origin.longitude}' : '';
    final apple = Uri.parse(
      'https://maps.apple.com/'
      '?daddr=${dest.latitude},${dest.longitude}'
      '$originPart'
      '&dirflg=d', // d = driving
    );
    if (await canLaunchUrl(apple)) {
      await launchUrl(apple, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback: Google Maps app on iOS (needs LSApplicationQueriesSchemes in Info.plist)
    final googleApp = Uri.parse(
      'comgooglemaps://?daddr=${dest.latitude},${dest.longitude}'
      '$originPart&directionsmode=driving',
    );
    if (await canLaunchUrl(googleApp)) {
      await launchUrl(googleApp);
      return;
    }
  }

  // ── Universal fallback: Google Maps web URL ───────────────
  final originQuery =
      origin != null ? '&origin=${origin.latitude},${origin.longitude}' : '';
  final web = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '$originQuery'
    '&destination=${dest.latitude},${dest.longitude}'
    '&travelmode=driving',
  );
  await launchUrl(web, mode: LaunchMode.externalApplication);
}

// ─────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────
class PharmacyMapWidget extends StatefulWidget {
  final LatLng pharmacyLL;
  final String pharmacyName;
  final String pharmacyAddress;
  final String pharmacyCity;
  final String pharmacyProvince;
  final LatLng? seekerLL;

  const PharmacyMapWidget({
    super.key,
    required this.pharmacyLL,
    required this.pharmacyName,
    required this.pharmacyAddress,
    required this.pharmacyCity,
    required this.pharmacyProvince,
    this.seekerLL,
  });

  @override
  State<PharmacyMapWidget> createState() => _PharmacyMapState();
}

class _PharmacyMapState extends State<PharmacyMapWidget> {
  GoogleMapController? _ctrl;
  bool _ready = false;
  bool _loading = false;

  Set<Marker> _markers = {};
  Set<Polyline> _polys = {};
  String? _dist;
  String? _dur;
  bool _routeShown = false;

  /// Returns true when we have a valid seeker location.
  bool get _has =>
      widget.seekerLL != null &&
      (widget.seekerLL!.latitude != 0 || widget.seekerLL!.longitude != 0);

  static const _mapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#f8fdf8"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#2e7d32"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#388e3c"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#a5d6a7"}]},
    {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#81c784"}]},
    {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#1b5e20"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#b3e5fc"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#01579b"}]},
    {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#c8e6c9"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#f1f8e9"}]},
    {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#e8f5e9"}]}
  ]''';

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _ctrl = null;
    super.dispose();
  }

  void _buildMarkers() {
    final m = <Marker>{};
    m.add(Marker(
      markerId: const MarkerId('pharmacy'),
      position: widget.pharmacyLL,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: widget.pharmacyName,
        snippet: widget.pharmacyAddress,
      ),
    ));
    if (_has) {
      m.add(Marker(
        markerId: const MarkerId('seeker'),
        position: widget.seekerLL!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: AppLocalizations.of(context)!.your_location_label),
      ));
    }
    _markers = m;
  }

  void _fly(LatLng t, {double z = 17, double tilt = 40, double bear = 15}) {
    if (!_ready || _ctrl == null) return;
    _ctrl!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: t, zoom: z, tilt: tilt, bearing: bear),
    ));
  }

  void _fit() {
    if (!_ready || _ctrl == null || !_has) {
      _fly(widget.pharmacyLL);
      return;
    }
    final s = widget.seekerLL!;
    final p = widget.pharmacyLL;
    _ctrl!.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
        southwest: LatLng(
          math.min(s.latitude, p.latitude),
          math.min(s.longitude, p.longitude),
        ),
        northeast: LatLng(
          math.max(s.latitude, p.latitude),
          math.max(s.longitude, p.longitude),
        ),
      ),
      80,
    ));
  }

  // ── Route toggle ──────────────────────────────────────────
  Future<void> _toggleRoute() async {
    if (!_has || _loading) return;

    // Hide route if already shown
    if (_routeShown) {
      setState(() {
        _routeShown = false;
        _polys = {};
        _dist = null;
        _dur = null;
      });
      _fly(widget.pharmacyLL);
      return;
    }

    setState(() => _loading = true);

    try {
      final res = await http
          .get(Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${widget.seekerLL!.latitude},${widget.seekerLL!.longitude}'
            '&destination=${widget.pharmacyLL.latitude},${widget.pharmacyLL.longitude}'
            '&mode=driving&key=$_key',
          ))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      List<LatLng> pts = [];
      String dist =
          '~${_km(widget.seekerLL!, widget.pharmacyLL).toStringAsFixed(1)} km';
      String dur = '';

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map;
        if (body['status'] == 'OK') {
          final route = (body['routes'] as List).first;
          final leg = (route['legs'] as List).first;
          pts = _decode(route['overview_polyline']['points'] as String);
          dist = leg['distance']['text'] as String;
          dur = leg['duration']['text'] as String;
        }
      }

      // Fallback: straight line between the two points
      if (pts.isEmpty) pts = [widget.seekerLL!, widget.pharmacyLL];

      setState(() {
        _polys = {
          Polyline(
            polylineId: const PolylineId('shadow'),
            points: pts,
            color: AppColors.darkGreen.withOpacity(.25),
            width: 6,
          ),
          Polyline(
            polylineId: const PolylineId('route'),
            points: pts,
            color: AppColors.darkGreen,
            width: 4,
          ),
        };
        _dist = dist;
        _dur = dur;
        _routeShown = true;
        _loading = false;
      });

      _fit();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkGreen.withOpacity(.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── HEADER ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            color: AppColors.darkGreen,
            child: Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_outline_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.pharmacyName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text(
                      widget.pharmacyAddress.isNotEmpty
                          ? widget.pharmacyAddress
                          : '${widget.pharmacyCity}, ${widget.pharmacyProvince}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_has)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '~${_km(widget.seekerLL!, widget.pharmacyLL).toStringAsFixed(1)} km',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ]),
          ),

          // ── MAP ──────────────────────────────────────────
          SizedBox(
            height: 240,
            child: Stack(children: [
              GoogleMap(
                key: ValueKey('map_${widget.pharmacyLL.latitude}'),
                mapType: MapType.normal,
                initialCameraPosition: _has
                    ? CameraPosition(
                        target: LatLng(
                          (widget.pharmacyLL.latitude +
                                  widget.seekerLL!.latitude) /
                              2,
                          (widget.pharmacyLL.longitude +
                                  widget.seekerLL!.longitude) /
                              2,
                        ),
                        zoom: 11,
                      )
                    : CameraPosition(
                        target: widget.pharmacyLL,
                        zoom: 17,
                        tilt: 40,
                        bearing: 15,
                      ),
                markers: _markers,
                polylines: _polys,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                onMapCreated: (c) async {
                  _ctrl = c;
                  _ready = true;
                  await c.setMapStyle(_mapStyle);
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!mounted) return;
                  _has ? _fit() : _fly(widget.pharmacyLL);
                },
              ),

              // Loading spinner
              if (_loading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white60,
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(
                            color: AppColors.darkGreen, strokeWidth: 2),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.getting_route_loading,
                            style: TextStyle(
                                color: AppColors.darkGreen, fontSize: 12)),
                      ]),
                    ),
                  ),
                ),

              // Distance + duration pill
              if (_dist != null)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.darkGreen.withOpacity(.3)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 8),
                        ],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.route_rounded,
                            color: AppColors.darkGreen, size: 14),
                        const SizedBox(width: 6),
                        Text(_dist!,
                            style: TextStyle(
                                color: AppColors.darkGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        if (_dur!.isNotEmpty) ...[
                          Container(
                              width: 1,
                              height: 12,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              color: AppColors.darkGreen.withOpacity(.3)),
                          Icon(Icons.access_time_rounded,
                              color: Colors.grey.shade500, size: 13),
                          const SizedBox(width: 4),
                          Text(_dur!,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 11)),
                        ],
                      ]),
                    ),
                  ),
                ),
            ]),
          ),

          // ── FROM → TO strip ──────────────────────────────
          if (_has)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(.3), blurRadius: 4)
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(AppLocalizations.of(context)!.your_location_label,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: List.generate(
                        6,
                        (_) => Expanded(
                          child: Container(
                            height: 1.5,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            color: AppColors.darkGreen.withOpacity(.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Icon(Icons.work_outline_rounded,
                    color: AppColors.darkGreen, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.pharmacyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),

          // ── BUTTONS (only 2) ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              // Button 1: Show / Hide Route
              if (_has) ...[
                Expanded(
                  child: _MapBtn(
                    icon: _routeShown
                        ? Icons.close_rounded
                        : Icons.route_rounded,
                    label: _routeShown ? AppLocalizations.of(context)!.hide_route_btn : AppLocalizations.of(context)!.show_route_btn,
                    color: _routeShown ? Colors.white : AppColors.darkGreen,
                    filled: _routeShown,
                    fillColor:
                        _routeShown ? AppColors.darkGreen : null,
                    onTap: () {
                      if (!_loading) _toggleRoute();
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Button 2: Open in Maps
              Expanded(
                child: _MapBtn(
                  icon: Icons.map_rounded,
                  label: AppLocalizations.of(context)!.open_in_maps_btn,
                  color: Colors.white,
                  filled: true,
                  fillColor: AppColors.darkGreen,
                  onTap: () => _openInMaps(
                    dest: widget.pharmacyLL,
                    origin: _has ? widget.seekerLL : null,
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _MapBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  final Color? fillColor;

  const _MapBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    required this.onTap,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? (fillColor ?? AppColors.darkGreen)
        : AppColors.darkGreen.withOpacity(.06);
    final border = filled
        ? (fillColor ?? AppColors.darkGreen)
        : AppColors.darkGreen.withOpacity(.25);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}