import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../widgets/shared_widgets.dart';

class MapScreen extends StatefulWidget {
  final ChildModel? activeChild;
  final List<ChildModel> children;
  final Function(String) go;
  final AppTheme T;

  const MapScreen({
    super.key,
    this.activeChild,
    required this.children,
    required this.go,
    required this.T,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // ── Map controller ───────────────────────────────
  GoogleMapController? _mapController;

  // ── Selected child ───────────────────────────────
  late ChildModel? _selected;

  // ── Default position (Kandy) ─────────────────────
  static const LatLng _kDefaultPos = LatLng(7.2906, 80.6337);

  // ── Child live position ──────────────────────────
  LatLng _childPosition = _kDefaultPos;
  bool _locationLoaded = false;

  // ── Polling timer ────────────────────────────────
  Timer? _locationTimer;

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
    super.dispose();
  }

  // ── Start polling every 5 seconds ────────────────
  void _startPolling() {
    _fetchLocation();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchLocation(),
    );
  }

  // ── Fetch child location from backend ────────────
  Future<void> _fetchLocation() async {
    if (_selected == null) return;

    final loc = await LocationService.fetchLocation(_selected!.id);
    if (loc == null || !mounted) return;

    final newPos = LatLng(loc.lat, loc.lng);

    setState(() {
      _childPosition = newPos;
      _locationLoaded = true;
    });

    // Smooth camera movement
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
  }

  // ── Marker for child ─────────────────────────────
  Set<Marker> get _markers {
    if (_selected == null) return {};

    return {
      Marker(
        markerId: const MarkerId('child'),
        position: _childPosition,
        infoWindow: InfoWindow(
          title: _selected!.name,
          snippet: _selected!.status,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    if (widget.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'No Children Added',
              style: TextStyle(
                color: T.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a child to start tracking.',
              style: TextStyle(color: T.sub),
            ),
            const SizedBox(height: 24),
            PrimaryBtn(
              label: '➕ Add a Child',
              onTap: () => widget.go('addchild'),
              T: T,
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _childPosition, zoom: 14.0),
      mapType: MapType.normal,
      onMapCreated: (controller) {
        _mapController = controller;

        if (_locationLoaded) {
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(_childPosition, 14),
          );
        }
      },
      markers: _markers,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
    );
  }
}
