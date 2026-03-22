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
  final List<ZoneModel> zones;
  final Function(String) go;
  final AppTheme T;

  const MapScreen({
    super.key,
    this.activeChild,
    required this.children,
    required this.zones,
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

  // ── Filter zones for selected child ──────────────
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
    super.dispose();
  }

  // ── Polling ──────────────────────────────────────
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
    });

    _startPolling();
  }

  // ── Get zone position ─────────────────────────────
  LatLng _posForZone(ZoneModel z) {
    if (z.lat != null && z.lng != null) {
      return LatLng(z.lat!, z.lng!);
    }
    return _childPosition;
  }

  // ── Markers ───────────────────────────────────────
  Set<Marker> get _markers {
    final markers = <Marker>{};

    // Child marker
    if (_selected != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('child'),
          position: _childPosition,
          infoWindow: InfoWindow(
            title: _selected!.name,
            snippet: _selected!.status,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            HSLColor.fromColor(Color(_selected!.colorHex)).hue,
          ),
        ),
      );
    }

    // Zone markers
    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      final pos = _posForZone(z);

      markers.add(
        Marker(
          markerId: MarkerId('zone_$i'),
          position: pos,
          infoWindow: InfoWindow(
            title: z.name,
            snippet: '${z.start} → ${z.end}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return markers;
  }

  // ── Circles (Safe zones) ──────────────────────────
  Set<Circle> get _circles {
    final circles = <Circle>{};

    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      final pos = _posForZone(z);
      final color = Color(z.colorHex);

      circles.add(
        Circle(
          circleId: CircleId('zone_$i'),
          center: pos,
          radius: z.radius.toDouble(),
          fillColor: color.withOpacity(0.2),
          strokeColor: color,
          strokeWidth: 2,
        ),
      );
    }

    return circles;
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

    final c = _selected ?? widget.children.first;

    return Column(
      children: [
        // ── Top bar (same as commit 2) ───────────────
        Container(
          color: T.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
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
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: T.text,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.children.map((child) {
                      final isSelected = child.id == c.id;
                      final color = Color(child.colorHex);

                      return GestureDetector(
                        onTap: () => _switchChild(child),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : T.card2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? color : T.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(child.avatar),
                              const SizedBox(width: 5),
                              Text(
                                child.name,
                                style: TextStyle(
                                  color: isSelected ? color : T.text,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              if (_locationLoaded)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: T.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: T.green.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Map ──────────────────────────────────────
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _childPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;

              if (_locationLoaded) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_childPosition, 14),
                );
              }
            },
            markers: _markers,
            circles: _circles, // 🔥 NEW
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),
        ),
      ],
    );
  }
}
