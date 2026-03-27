import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

const _kCities = [
  ('Colombo', 6.9271, 79.8612),
  ('Kandy', 7.2906, 80.6337),
  ('Galle', 6.0535, 80.2210),
  ('Negombo', 7.2081, 79.8358),
  ('Jaffna', 9.6615, 80.0255),
  ('Trincomalee', 8.5874, 81.2152),
  ('Batticaloa', 7.7170, 81.6924),
  ('Anuradhapura', 8.3114, 80.4037),
  ('Polonnaruwa', 7.9403, 81.0188),
  ('Badulla', 6.9934, 81.0550),
  ('Kurunegala', 7.4863, 80.3647),
  ('Ratnapura', 6.6828, 80.3992),
  ('Matara', 5.9549, 80.5550),
  ('Hambantota', 6.1249, 81.1185),
  ('Nuwara Eliya', 6.9497, 80.7891),
  ('Dambulla', 7.8731, 80.6517),
  ('Puttalam', 8.0362, 79.8283),
  ('Kalutara', 6.5854, 79.9607),
  ('Moratuwa', 6.7730, 79.8820),
  ('Kotte', 6.8996, 79.9009),
  ('Vavuniya', 8.7514, 80.4971),
  ('Mannar', 8.9800, 79.9047),
  ('Matale', 7.4675, 80.6234),
  ('Panadura', 6.7137, 79.9070),
  ('Kalmunai', 7.4148, 81.8268),
];

class TrackingScreen extends StatefulWidget {
  final ChildModel? child;
  final List<ChildModel> children;
  final List<ZoneModel> zones;
  final Function(ZoneModel) onAddZone;
  final Function(String) go;
  final AppTheme T;
  const TrackingScreen({
    super.key,
    this.child,
    required this.children,
    required this.zones,
    required this.onAddZone,
    required this.go,
    required this.T,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late ChildModel? _selected;

  // ── Google Maps
  GoogleMapController? _mapController;

  static const _kDefaultPos = LatLng(7.2906, 80.6337);
  LatLng _childPosition = _kDefaultPos;

  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _startFocus = false;
  bool _endFocus = false;
  bool _routeSaved = false;

  List<ZoneModel> get _myZones => _selected == null
      ? []
      : widget.zones.where((z) => z.childId == _selected!.id).toList();

  List<Map<String, dynamic>> _placeSuggestions = [];
  double? _selectedStartLat;
  double? _selectedStartLng;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selected = widget.child ??
        (widget.children.isNotEmpty ? widget.children.first : null);
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _saveZone() {
    if (_startCtrl.text.trim().isEmpty || _endCtrl.text.trim().isEmpty) return;
    final c = _selected;
    if (c == null) return;
    final zone = ZoneModel(
      id: DateTime.now().millisecondsSinceEpoch,
      childId: c.id,
      name: _startCtrl.text.split(',').first.trim(),
      icon: '📍',
      start: _startCtrl.text.trim(),
      end: _endCtrl.text.trim(),
      radius: 500,
      colorHex: c.colorHex,
      lat: _selectedStartLat,
      lng: _selectedStartLng,
      active: true,
      inZone: true,
    );
    widget.onAddZone(zone);
    _startCtrl.clear();
    _endCtrl.clear();

    if (_selectedStartLat != null && _selectedStartLng != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_selectedStartLat!, _selectedStartLng!), 13));
    } else {
      final startName = zone.start.toLowerCase();
      for (final city in _kCities) {
        if (city.$1.toLowerCase().contains(startName) ||
            startName.contains(city.$1.toLowerCase())) {
          _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(city.$2, city.$3), 13));
          break;
        }
      }
    }

    setState(() {
      _routeSaved = true;
      _startFocus = false;
      _endFocus = false;
      _selectedStartLat = null;
      _selectedStartLng = null;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _routeSaved = false);
    });
  }

  // Uses the Places Autocomplete API to get suggestions.
  Future<void> _fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _placeSuggestions = []);
      return;
    }
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': input,
          'components': 'country:lk',
          'language': 'en',
          'key': 'AIzaSyDciOgl_Tz7PvEeC-GbQOtI3h52BDKqKwE',
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK') {
          final predictions =
              (data['predictions'] as List).cast<Map<String, dynamic>>();
          if (mounted) {
            setState(() => _placeSuggestions = predictions.take(5).toList());
          }
        }
      }
    } catch (e) {
      print('[TrackingScreen] Places autocomplete error: $e');
    }
  }

  // Geocode a place_id to get its LatLng.
  Future<void> _selectPlace(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'] as String;
    final description = prediction['description'] as String;

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'geometry',
          'key': 'AIzaSyDciOgl_Tz7PvEeC-GbQOtI3h52BDKqKwE',
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'OK') {
          final loc = data['result']['geometry']['location'];
          final dest = LatLng(
              (loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
          setState(() {
            if (_startFocus) {
              _startCtrl.text = description;
              _selectedStartLat = dest.latitude;
              _selectedStartLng = dest.longitude;
            } else if (_endFocus) {
              _endCtrl.text = description;
            }
            _placeSuggestions = [];
          });
          FocusScope.of(context).unfocus();
        }
      }
    } catch (e) {
      print('[TrackingScreen] Place details error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    if (widget.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📍', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No Children Added',
              style: TextStyle(
                  color: T.text, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add a child to start live tracking.',
              style: TextStyle(color: T.sub, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PrimaryBtn(
              label: '➕ Add a Child', onTap: () => widget.go('addchild'), T: T),
        ]),
      );
    }

    if (_selected == null ||
        !widget.children.any((c) => c.id == _selected!.id)) {
      _selected = widget.children.first;
    }

    final c = _selected!;
    final color = Color(c.colorHex);

    return Column(children: [
      Container(
        color: T.surface,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(children: [
              GestureDetector(
                onTap: () => widget.go('dashboard'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: T.card2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.border),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: T.text, size: 15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.children.asMap().entries.map((e) {
                      final k = e.value;
                      final kc = Color(k.colorHex);
                      final sel = k.id == c.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selected = k;
                            _routeSaved = false;
                          });
                          _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(_childPosition, 13));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right:
                                  e.key < widget.children.length - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? kc.withOpacity(0.15) : T.card2,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: sel ? kc : T.border,
                                width: sel ? 1.5 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(k.avatar,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            Text(k.name,
                                style: TextStyle(
                                  color: sel ? kc : T.text,
                                  fontSize: 12,
                                  fontWeight:
                                      sel ? FontWeight.w700 : FontWeight.w500,
                                )),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ]),
          ),

          // ── Route input card (Uber style) ─────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _startFocus || _endFocus ? color : T.border,
                width: _startFocus || _endFocus ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(children: [
              // Starting point row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Row(children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: T.green,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) => setState(() {
                        _startFocus = f;
                        if (f) _endFocus = false;
                      }),
                      child: TextField(
                        controller: _startCtrl,
                        onChanged: (v) {
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 350),
                              () => _fetchPlaceSuggestions(v));
                        },
                        style: TextStyle(color: T.text, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Starting point',
                          hintStyle: TextStyle(color: T.muted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  if (_startCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _startCtrl.clear();
                        setState(() {});
                      },
                      child:
                          Icon(Icons.close_rounded, color: T.muted, size: 16),
                    ),
                ]),
              ),

              // Dotted connector
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Column(
                  children: List.generate(
                      3,
                      (_) => Container(
                            width: 2,
                            height: 4,
                            margin: const EdgeInsets.symmetric(vertical: 1.5),
                            decoration: BoxDecoration(
                                color: T.border,
                                borderRadius: BorderRadius.circular(1)),
                          )),
                ),
              ),

              // Ending point row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                child: Row(children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: T.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) => setState(() {
                        _endFocus = f;
                        if (f) _startFocus = false;
                      }),
                      child: TextField(
                        controller: _endCtrl,
                        onChanged: (v) {
                          _debounce?.cancel();
                          _debounce = Timer(const Duration(milliseconds: 350),
                              () => _fetchPlaceSuggestions(v));
                        },
                        style: TextStyle(color: T.text, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Where to?',
                          hintStyle: TextStyle(color: T.muted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  if (_endCtrl.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _endCtrl.clear();
                        setState(() {});
                      },
                      child:
                          Icon(Icons.close_rounded, color: T.muted, size: 16),
                    ),
                ]),
              ),
            ]),
          ),

          if (_placeSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: T.card,
                border: Border(
                  left: BorderSide(color: T.border),
                  right: BorderSide(color: T.border),
                  bottom: BorderSide(color: T.border),
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: _placeSuggestions.map((p) {
                  final main = (p['structured_formatting']?['main_text'] ??
                      p['description']) as String;
                  final sub = (p['structured_formatting']?['secondary_text'] ??
                      '') as String;
                  return InkWell(
                    onTap: () => _selectPlace(p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(children: [
                        Icon(Icons.location_on_outlined,
                            color: T.sub, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(main,
                                  style: TextStyle(
                                      color: T.text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              if (sub.isNotEmpty)
                                Text(sub,
                                    style:
                                        TextStyle(color: T.sub, fontSize: 11)),
                            ])),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: _routeSaved
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: T.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: T.green.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Icon(Icons.check_circle_rounded,
                          color: T.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'Safe zone saved! Visible on map & Safe Zones page.',
                            style: TextStyle(
                                color: T.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  )
                : (_startCtrl.text.isNotEmpty && _endCtrl.text.isNotEmpty)
                    ? PrimaryBtn(
                        label: '🛡️  Save as Safe Zone for ${c.name}',
                        onTap: _saveZone,
                        T: T,
                      )
                    : Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: T.muted, size: 14),
                        const SizedBox(width: 6),
                        Text('Enter start & end to save a safe zone',
                            style: TextStyle(color: T.muted, fontSize: 11)),
                      ]),
          ),
        ]),
      ),
      Expanded(
        child: Stack(children: [
          // ── Real Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _childPosition,
              zoom: 13.0,
            ),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              FocusScope.of(context).unfocus();
              setState(() {
                _startFocus = false;
                _endFocus = false;
                _placeSuggestions = [];
              });
            },
            // Child location marker
            markers: {
              Marker(
                markerId: const MarkerId('child'),
                position: _childPosition,
                infoWindow: InfoWindow(
                  title: c.name,
                  snippet: c.status,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  HSLColor.fromColor(color).hue,
                ),
              ),
              // Safe zone centre markers
              ..._myZones.asMap().entries.map((e) {
                final z = e.value;
                // Find the real GPS position for this zone's start city
                LatLng pos = _childPosition;
                if (z.lat != null && z.lng != null) {
                  pos = LatLng(z.lat!, z.lng!);
                } else {
                  final st = z.start.toLowerCase();
                  for (final city in _kCities) {
                    if (city.$1.toLowerCase().contains(st) ||
                        st.contains(city.$1.toLowerCase())) {
                      pos = LatLng(city.$2, city.$3);
                      break;
                    }
                  }
                }
                return Marker(
                  markerId: MarkerId('zone_${e.key}'),
                  position: pos,
                  infoWindow: InfoWindow(
                    title: '${z.icon} ${z.name}',
                    snippet: '${z.start} → ${z.end}',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                );
              }),
            },
            // Safe zone radius circles
            circles: {
              ..._myZones.asMap().entries.map((e) {
                final z = e.value;
                LatLng pos = _childPosition;
                if (z.lat != null && z.lng != null) {
                  pos = LatLng(z.lat!, z.lng!);
                } else {
                  final st = z.start.toLowerCase();
                  for (final city in _kCities) {
                    if (city.$1.toLowerCase().contains(st) ||
                        st.contains(city.$1.toLowerCase())) {
                      pos = LatLng(city.$2, city.$3);
                      break;
                    }
                  }
                }
                final col = Color(z.colorHex);
                return Circle(
                  circleId: CircleId('zone_circle_${e.key}'),
                  center: pos,
                  radius: z.radius.toDouble(),
                  fillColor: col.withOpacity(0.15),
                  strokeColor: col,
                  strokeWidth: 2,
                );
              }),
            },
          ),

          // Zones overlay
          if (_myZones.isNotEmpty)
            Positioned(
              bottom: 70,
              left: 12,
              right: 62,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Text(
                      'SAFE ZONES (${_myZones.length})',
                      style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1),
                    ),
                  ),
                  ..._myZones.map((z) => Container(
                        margin: const EdgeInsets.only(top: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          border: Border(
                              left: BorderSide(
                                  color: Color(z.colorHex), width: 3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(z.icon, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(z.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                Text('${z.start} → ${z.end}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 9)),
                              ]),
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: z.inZone
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ]),
                      )),
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

          // No zones hint
          if (_myZones.isEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shield_outlined, color: Colors.white54, size: 14),
                  SizedBox(width: 6),
                  Text('No safe zones · add one above',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
              ),
            ),

          // My location / re-centre button
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_childPosition, 14)),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Color(0xFF1A73E8), size: 22),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}
