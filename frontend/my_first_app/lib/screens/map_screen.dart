import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/shared_widgets.dart';

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
  GoogleMapController? _mapController;

  late ChildModel? _selected;

  static const LatLng _kDefaultPos = LatLng(7.2906, 80.6337);

  LatLng _childPosition = _kDefaultPos;
  bool _locationLoaded = false;

  Timer? _locationTimer;

  // ── Safe zone inputs ─────────────────────────────
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _zoneSaved = false;

  // ── Places API ───────────────────────────────────
  List<Map<String, dynamic>> _placeSuggestions = [];
  Timer? _debounce;

  // ── Filter zones ────────────────────────────────
  List<ZoneModel> get _myZones => _selected == null
      ? []
      : widget.zones.where((z) => z.childId == _selected!.id).toList();

  @override
  void initState() {
    super.initState();
    _selected =
        widget.activeChild ??
        (widget.children.isNotEmpty ? widget.children.first : null);
    _startPolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Polling ─────────────────────────────────────
  void _startPolling() {
    _fetchLocation();
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

    _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
  }

  void _switchChild(ChildModel child) {
    setState(() {
      _selected = child;
      _locationLoaded = false;
      _childPosition = _kDefaultPos;
      _zoneSaved = false;
    });

    _startPolling();
  }

  // ════════════════════════════════════════════════
  //  GOOGLE PLACES API
  // ════════════════════════════════════════════════

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
          'key': 'YOUR_API_KEY_HERE',
        },
      );

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['status'] == 'OK') {
          setState(() {
            _placeSuggestions = List<Map<String, dynamic>>.from(
              data['predictions'],
            );
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> place) async {
    final placeId = place['place_id'];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {'place_id': placeId, 'fields': 'geometry', 'key': 'YOUR_API_KEY_HERE'},
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final loc = data['result']['geometry']['location'];

      final LatLng selectedPos = LatLng(loc['lat'], loc['lng']);

      setState(() {
        _childPosition = selectedPos; // temp move
        _placeSuggestions = [];
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedPos, 14),
      );
    }
  }

  // ── Save zone ───────────────────────────────────
  void _saveZone() {
    if (_startCtrl.text.isEmpty || _endCtrl.text.isEmpty) return;
    if (_selected == null) return;

    final c = _selected!;

    widget.onAddZone(
      ZoneModel(
        id: DateTime.now().millisecondsSinceEpoch,
        childId: c.id,
        name: _startCtrl.text,
        icon: '📍',
        start: _startCtrl.text,
        end: _endCtrl.text,
        radius: 500,
        colorHex: c.colorHex,
        lat: _childPosition.latitude,
        lng: _childPosition.longitude,
        active: true,
        inZone: true,
      ),
    );

    setState(() => _zoneSaved = true);
  }

  // ── Markers ─────────────────────────────────────
  Set<Marker> get _markers => {
    Marker(markerId: const MarkerId('child'), position: _childPosition),
  };

  // ── Circles ─────────────────────────────────────
  Set<Circle> get _circles => _myZones.map((z) {
    return Circle(
      circleId: CircleId('${z.id}'),
      center: LatLng(z.lat!, z.lng!),
      radius: z.radius.toDouble(),
      fillColor: Colors.blue.withOpacity(0.2),
      strokeColor: Colors.blue,
    );
  }).toSet();

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return Column(
      children: [
        // ── Input + autocomplete ────────────────────
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _startCtrl,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () => _fetchPlaceSuggestions(value),
                  );
                },
                decoration: const InputDecoration(hintText: 'Search location'),
              ),

              // Dropdown
              if (_placeSuggestions.isNotEmpty)
                Container(
                  height: 150,
                  child: ListView(
                    children: _placeSuggestions.map((p) {
                      return ListTile(
                        title: Text(p['description']),
                        onTap: () => _selectPlace(p),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),

        // ── Map ─────────────────────────────────────
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _childPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            circles: _circles,
          ),
        ),
      ],
    );
  }
}
