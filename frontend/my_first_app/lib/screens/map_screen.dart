import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../models.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';

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

  static const LatLng _kDefaultPos = LatLng(7.2906, 80.6337);

  LatLng _childPosition = _kDefaultPos;
  LatLng? _destinationPos;
  String _destinationName = '';

  bool _locationLoaded = false;

  Timer? _locationTimer;
  Timer? _debounce;

  List<Map<String, dynamic>> _placeSuggestions = [];

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  //Polling
  void _startPolling() {
    _fetchLocation();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchLocation(),
    );
  }

  Future<void> _fetchLocation() async {
    final loc = await LocationService.fetchLocation(1);
    if (loc == null || !mounted) return;

    final newPos = LatLng(loc.lat, loc.lng);

    setState(() {
      _childPosition = newPos;
      _locationLoaded = true;
    });
  }

  // Places API
  Future<void> _fetchPlaceSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _placeSuggestions = []);
      return;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/autocomplete/json',
      {'input': input, 'key': 'YOUR_API_KEY'},
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

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _childPosition.latitude < dest.latitude
                  ? _childPosition.latitude
                  : dest.latitude,
              _childPosition.longitude < dest.longitude
                  ? _childPosition.longitude
                  : dest.longitude,
            ),
            northeast: LatLng(
              _childPosition.latitude > dest.latitude
                  ? _childPosition.latitude
                  : dest.latitude,
              _childPosition.longitude > dest.longitude
                  ? _childPosition.longitude
                  : dest.longitude,
            ),
          ),
          80,
        ),
      );
    }
  }

  // Markers
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
    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _childPosition,
            zoom: 14,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (_) {
            FocusScope.of(context).unfocus();
            setState(() => _placeSuggestions = []);
          },
          markers: _markers,
          zoomControlsEnabled: false,
          compassEnabled: true,
        ),

        // Search UI
        Positioned(
          top: 40,
          left: 12,
          right: 12,
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
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search location...',
                  border: OutlineInputBorder(),
                ),
              ),

              if (_placeSuggestions.isNotEmpty)
                Container(
                  color: Colors.white,
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

        // Recenter
        Positioned(
          bottom: 20,
          right: 12,
          child: FloatingActionButton(
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_childPosition, 14),
              );
            },
            child: const Icon(Icons.my_location),
          ),
        ),

        // Loading
        if (!_locationLoaded)
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
