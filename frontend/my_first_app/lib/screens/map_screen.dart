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

  // ── Destination ────────────────────────────────
  LatLng? _destinationPos;
  String _destinationName = '';

  // ── Places ────────────────────────────────────
  List<Map<String, dynamic>> _placeSuggestions = [];
  Timer? _debounce;

  // ── Inputs ────────────────────────────────────
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  // ── Zones ─────────────────────────────────────
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

  // ── Polling ────────────────────────────────────
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
      _childPosition = _kDefaultPos;
      _destinationPos = null;
    });

    _startPolling();
  }

  // ════════════════════════════════════════════════
  //  GOOGLE PLACES
  // ════════════════════════════════════════════════

  Future<void> _fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _placeSuggestions = []);
      return;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {'input': input, 'components': 'country:lk', 'key': 'YOUR_API_KEY'},
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data['status'] == 'OK') {
        setState(() {
          _placeSuggestions = List.from(data['predictions']);
        });
      }
    }
  }

  Future<void> _selectPlace(Map<String, dynamic> place) async {
    final placeId = place['place_id'];
    final description = place['description'];

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/details/json',
      {'place_id': placeId, 'fields': 'geometry', 'key': 'YOUR_API_KEY'},
    );

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final loc = data['result']['geometry']['location'];

      final dest = LatLng(loc['lat'], loc['lng']);

      setState(() {
        _destinationPos = dest;
        _destinationName = description;
        _placeSuggestions = [];
      });

      // 🔥 Fit both child + destination
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              (_childPosition.latitude < dest.latitude
                      ? _childPosition.latitude
                      : dest.latitude) -
                  0.02,
              (_childPosition.longitude < dest.longitude
                      ? _childPosition.longitude
                      : dest.longitude) -
                  0.02,
            ),
            northeast: LatLng(
              (_childPosition.latitude > dest.latitude
                      ? _childPosition.latitude
                      : dest.latitude) +
                  0.02,
              (_childPosition.longitude > dest.longitude
                      ? _childPosition.longitude
                      : dest.longitude) +
                  0.02,
            ),
          ),
          80,
        ),
      );
    }
  }

  // ── Markers ─────────────────────────────────────
  Set<Marker> get _markers {
    final markers = <Marker>{};

    markers.add(
      Marker(markerId: const MarkerId('child'), position: _childPosition),
    );

    if (_destinationPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationPos!,
          infoWindow: InfoWindow(title: _destinationName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search box ──────────────────────────────
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () => _fetchPlaceSuggestions(v),
                  );
                },
                decoration: const InputDecoration(
                  hintText: 'Search destination',
                ),
              ),

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
          ),
        ),
      ],
    );
  }
}
