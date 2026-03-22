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
  final Function(ZoneModel) onAddZone; // NEW
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
  bool _startFocus = false;
  bool _endFocus = false;
  bool _zoneSaved = false;

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

  // ── Save zone logic ─────────────────────────────
  void _saveZone() {
    if (_startCtrl.text.trim().isEmpty ||
        _endCtrl.text.trim().isEmpty ||
        _selected == null)
      return;

    final c = _selected!;

    widget.onAddZone(
      ZoneModel(
        id: DateTime.now().millisecondsSinceEpoch,
        childId: c.id,
        name: _startCtrl.text.split(',').first,
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

    _startCtrl.clear();
    _endCtrl.clear();

    setState(() => _zoneSaved = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _zoneSaved = false);
    });
  }

  // ── Zone position ───────────────────────────────
  LatLng _posForZone(ZoneModel z) {
    if (z.lat != null && z.lng != null) {
      return LatLng(z.lat!, z.lng!);
    }
    return _childPosition;
  }

  // ── Markers ─────────────────────────────────────
  Set<Marker> get _markers {
    final markers = <Marker>{};

    if (_selected != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('child'),
          position: _childPosition,
          infoWindow: InfoWindow(
            title: _selected!.name,
            snippet: _selected!.status,
          ),
        ),
      );
    }

    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      markers.add(
        Marker(
          markerId: MarkerId('zone_$i'),
          position: _posForZone(z),
          infoWindow: InfoWindow(title: z.name),
        ),
      );
    }

    return markers;
  }

  // ── Circles ─────────────────────────────────────
  Set<Circle> get _circles {
    final circles = <Circle>{};

    for (int i = 0; i < _myZones.length; i++) {
      final z = _myZones[i];
      final color = Color(z.colorHex);

      circles.add(
        Circle(
          circleId: CircleId('zone_$i'),
          center: _posForZone(z),
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

    final c = _selected ?? widget.children.first;

    return Column(
      children: [
        // ── Safe zone input UI ──────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          color: T.surface,
          child: Column(
            children: [
              // Start input
              TextField(
                controller: _startCtrl,
                onTap: () => setState(() {
                  _startFocus = true;
                  _endFocus = false;
                }),
                decoration: const InputDecoration(hintText: 'Safe zone start'),
              ),

              const SizedBox(height: 6),

              // End input
              TextField(
                controller: _endCtrl,
                onTap: () => setState(() {
                  _endFocus = true;
                  _startFocus = false;
                }),
                decoration: const InputDecoration(hintText: 'Safe zone end'),
              ),

              const SizedBox(height: 8),

              // Save button or message
              _zoneSaved
                  ? const Text(
                      '✅ Zone saved successfully',
                      style: TextStyle(color: Colors.green),
                    )
                  : ElevatedButton(
                      onPressed: _saveZone,
                      child: Text('Save Safe Zone for ${c.name}'),
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
