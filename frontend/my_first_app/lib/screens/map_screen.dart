import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../utils/api_config.dart';
import '../widgets/shared_widgets.dart';

// ═════════════════════════════════════════════════════════
//  MAP SCREEN
//  - Real Google Map
//  - Polls GET /location/{child_id} every 5 seconds
//  - Updates marker + smoothly moves camera
//  - Places API search bar with autocomplete suggestions
//  - Safe zone radius circles from shared zones list
//  - Does NOT break existing navigation or UI structure
// ═════════════════════════════════════════════════════════

class MapScreen extends StatefulWidget {
  final ChildModel? activeChild;
  final List<ChildModel> children;
  final List<ZoneModel> zones;
  final Function(ZoneModel) onAddZone;
  final Function(String) go;
  final AppTheme T;

  const MapScreen({
    super.key,
    this.activeChild,
    required this.children,
    required this.zones,
    required this.onAddZone,
    required this.go,
    required this.T,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ── Map controller ─────────────────────────────────────
  GoogleMapController? _mapController;

  // ── Currently selected child ───────────────────────────
  late ChildModel? _selected;

  // ── Child location (updated every 5 s) ─────────────────
  // Default: Kandy, Sri Lanka — replaced immediately on first poll
  static const LatLng _kDefaultPos = LatLng(7.2906, 80.6337);
  LatLng _childPosition = _kDefaultPos;
  bool _locationLoaded = false;

  // ── Timer for 5-second polling ─────────────────────────
  Timer? _locationTimer;

  // ── Safe zone input ────────────────────────────────────
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _startFocus = false;
  bool _endFocus = false;
  bool _zoneSaved = false;

  // ── Places search ──────────────────────────────────────
  List<Map<String, dynamic>> _placeSuggestions = [];
  double? _selectedStartLat;
  double? _selectedStartLng;
  Timer? _debounce;

  // ── Route (start = child pos, end = searched place) ────
  LatLng? _destinationPos;
  String _destinationName = '';

  // ── Markers & circles ──────────────────────────────────
  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Child marker
    if (_selected != null) {
      markers.add(Marker(
        markerId: const MarkerId('child'),
        position: _childPosition,
        infoWindow: InfoWindow(
          title: _selected!.name,
          snippet: _selected!.status,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          HSLColor.fromColor(Color(_selected!.colorHex)).hue,
        ),
      ));
    }

    // Destination marker (from Places search)
    if (_destinationPos != null) {
      markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: _destinationPos!,
        infoWindow: InfoWindow(title: _destinationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Zone centre markers
    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      final pos = _posForZone(z);
      markers.add(Marker(
        markerId: MarkerId('zone_$i'),
        position: pos,
        infoWindow: InfoWindow(
          title: '${z.icon} ${z.name}',
          snippet: '${z.start} → ${z.end}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    return markers;
  }

  Set<Circle> get _circles {
    final circles = <Circle>{};
    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      final col = Color(z.colorHex);
      circles.add(Circle(
        circleId: CircleId('zone_$i'),
        center: _posForZone(z),
        radius: z.radius.toDouble(),
        fillColor: col.withOpacity(0.15),
        strokeColor: col,
        strokeWidth: 2,
      ));
    }
    return circles;
  }

  // ── Safe zones for selected child ──────────────────────
  List<ZoneModel> get _myZones => _selected == null
      ? []
      : widget.zones.where((z) => z.childId == _selected!.id).toList();

  // ── City GPS lookup ────────────────────────────────────
  static const _kCities = [
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
    ('Kalutara', 6.5854, 79.9607),
    ('Moratuwa', 6.7730, 79.8820),
    ('Kotte', 6.8996, 79.9009),
    ('Vavuniya', 8.7514, 80.4971),
    ('Matale', 7.4675, 80.6234),
    ('Panadura', 6.7137, 79.9070),
  ];

  LatLng _posForZone(ZoneModel z) {
    if (z.lat != null && z.lng != null) return LatLng(z.lat!, z.lng!);
    final q = z.start.toLowerCase();
    for (final c in _kCities) {
      if (c.$1.toLowerCase().contains(q) || q.contains(c.$1.toLowerCase())) {
        return LatLng(c.$2, c.$3);
      }
    }
    return _childPosition;
  }

  @override
  void initState() {
    super.initState();
    _selected = widget.activeChild ??
        (widget.children.isNotEmpty ? widget.children.first : null);
    _startPolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _debounce?.cancel();
    _mapController?.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _startPolling() {
    _fetchLocation(); // fetch immediately on mount
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchLocation(),
    );
  }

  Future<void> _fetchLocation() async {
    if (_selected == null) return;
    final loc = await LocationService.fetchLocation(_selected!.id);
    if (loc == null || !mounted) return;

    final newPos = LatLng(loc.lat, loc.lng);
    setState(() {
      _childPosition = newPos;
      _locationLoaded = true;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPos),
    );
  }

  void _switchChild(ChildModel k) {
    setState(() {
      _selected = k;
      _locationLoaded = false;
      _childPosition = _kDefaultPos;
      _zoneSaved = false;
    });
    _startPolling();
  }

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
      print('[MapScreen] Places autocomplete error: $e');
    }
  }

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
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
          setState(() {
            _destinationPos = dest;
            _destinationName = description;
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
          // Fit map to show both child and destination
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  [_childPosition.latitude, dest.latitude]
                          .reduce((a, b) => a < b ? a : b) -
                      0.02,
                  [_childPosition.longitude, dest.longitude]
                          .reduce((a, b) => a < b ? a : b) -
                      0.02,
                ),
                northeast: LatLng(
                  [_childPosition.latitude, dest.latitude]
                          .reduce((a, b) => a > b ? a : b) +
                      0.02,
                  [_childPosition.longitude, dest.longitude]
                          .reduce((a, b) => a > b ? a : b) +
                      0.02,
                ),
              ),
              80,
            ),
          );
        }
      }
    } catch (e) {
      print('[MapScreen] Place details error: $e');
    }
  }

  void _saveZone() {
    if (_startCtrl.text.trim().isEmpty || _endCtrl.text.trim().isEmpty) return;
    if (_selected == null) return;
    final c = _selected!;
    widget.onAddZone(ZoneModel(
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
    ));
    _startCtrl.clear();
    _endCtrl.clear();
    setState(() {
      _zoneSaved = true;
      _selectedStartLat = null;
      _selectedStartLng = null;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _zoneSaved = false);
    });
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

    final c = _selected ?? widget.children.first;
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
                        onTap: () => _switchChild(k),
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
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Live indicator
              if (_locationLoaded)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: T.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: T.green.withOpacity(0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: T.green, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('LIVE',
                        style: TextStyle(
                            color: T.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                  ]),
                ),
            ]),
          ),

          // ── Safe zone route input (Uber style) ────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _startFocus || _endFocus ? color : T.border,
                width: _startFocus || _endFocus ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(children: [
              // Start
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Row(children: [
                  Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: T.green,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 2))),
                  const SizedBox(width: 10),
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
                      style: TextStyle(color: T.text, fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Safe zone start',
                          hintStyle: TextStyle(color: T.muted, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero),
                    ),
                  )),
                  if (_startCtrl.text.isNotEmpty)
                    GestureDetector(
                        onTap: () {
                          _startCtrl.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.close_rounded,
                            color: T.muted, size: 15)),
                ]),
              ),
              // Connector dots
              Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Column(
                      children: List.generate(
                          3,
                          (_) => Container(
                              width: 2,
                              height: 3,
                              margin: const EdgeInsets.symmetric(vertical: 1),
                              decoration: BoxDecoration(
                                  color: T.border,
                                  borderRadius: BorderRadius.circular(1)))))),
              // End
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                child: Row(children: [
                  Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                          color: T.red,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 10),
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
                      style: TextStyle(color: T.text, fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Safe zone end',
                          hintStyle: TextStyle(color: T.muted, fontSize: 12),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero),
                    ),
                  )),
                  if (_endCtrl.text.isNotEmpty)
                    GestureDetector(
                        onTap: () {
                          _endCtrl.clear();
                          setState(() {});
                        },
                        child: Icon(Icons.close_rounded,
                            color: T.muted, size: 15)),
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
                    bottom: BorderSide(color: T.border)),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
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
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: _zoneSaved
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: T.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: T.green.withOpacity(0.4))),
                    child: Row(children: [
                      Icon(Icons.check_circle_rounded,
                          color: T.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              'Zone saved — visible on map and Safe Zones page.',
                              style: TextStyle(
                                  color: T.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600))),
                    ]))
                : (_startCtrl.text.isNotEmpty && _endCtrl.text.isNotEmpty)
                    ? PrimaryBtn(
                        label: '🛡️  Save as Safe Zone for ${c.name}',
                        onTap: _saveZone,
                        T: T)
                    : Row(children: [
                        Icon(Icons.info_outline_rounded,
                            color: T.muted, size: 13),
                        const SizedBox(width: 6),
                        Text('Enter start & end to save a safe zone',
                            style: TextStyle(color: T.muted, fontSize: 11)),
                      ]),
          ),
        ]),
      ),
      Expanded(
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _childPosition,
              zoom: 14.0,
            ),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              // If we already have a location from the first poll, jump there
              if (_locationLoaded) {
                controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_childPosition, 14));
              }
            },
            onTap: (_) {
              FocusScope.of(context).unfocus();
              setState(() {
                _placeSuggestions = [];
              });
            },
            markers: _markers,
            circles: _circles,
          ),

          // ── Safe zones overlay (bottom-left) ─────────
          if (_myZones.isNotEmpty)
            Positioned(
              bottom: 70,
              left: 12,
              right: 66,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10))),
                    child: Text('SAFE ZONES (${_myZones.length})',
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                  ),
                  ..._myZones.map((z) => Container(
                        margin: const EdgeInsets.only(top: 1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            border: Border(
                                left: BorderSide(
                                    color: Color(z.colorHex), width: 3))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(z.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Flexible(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(z.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                                Text('${z.start} → ${z.end}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 9),
                                    overflow: TextOverflow.ellipsis),
                              ])),
                          const SizedBox(width: 6),
                          Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                  color: z.inZone
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFF87171),
                                  shape: BoxShape.circle)),
                        ]),
                      )),
                  Container(
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(10)))),
                ],
              ),
            ),

          if (_myZones.isEmpty)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.shield_outlined, color: Colors.white54, size: 13),
                  SizedBox(width: 6),
                  Text('No safe zones · add one above',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
              ),
            ),

          // ── Re-centre button ──────────────────────────
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
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: Color(0xFF1A73E8), size: 22),
              ),
            ),
          ),

          // ── Loading overlay (first fetch) ─────────────
          if (!_locationLoaded)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF34D399))),
                    const SizedBox(width: 8),
                    const Text('Fetching location…',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    ]);
  }
}
