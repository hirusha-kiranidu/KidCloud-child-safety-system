import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';

class SafeZoneScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  final List<ChildModel> children;
  final List<ZoneModel> zones;
  final Function(ZoneModel) onAddZone;
  final Function(ZoneModel) onUpdateZone;
  final Function(int) onDeleteZone;

  const SafeZoneScreen({
    super.key,
    required this.go,
    required this.T,
    required this.children,
    required this.zones,
    required this.onAddZone,
    required this.onUpdateZone,
    required this.onDeleteZone,
  });

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  int _childIdx = 0;
  bool _adding = false;

  final _nameCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  String _preset = 'Home';
  int _radius = 200;

  final _presets = ['Home', 'School', 'Tuition', 'Park', 'Mall'];
  final _radii = [100, 200, 500, 1000];

  ChildModel? get _child =>
      widget.children.isEmpty
          ? null
          : widget.children[_childIdx.clamp(0, widget.children.length - 1)];

  List<ZoneModel> get _myZones =>
      _child == null
          ? []
          : widget.zones.where((z) => z.childId == _child!.id).toList();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _saveZone() {
    if (_child == null) return;
    if (_startCtrl.text.isEmpty || _endCtrl.text.isEmpty) return;

    final zone = ZoneModel(
      id: DateTime.now().millisecondsSinceEpoch,
      childId: _child!.id,
      name: _nameCtrl.text.isEmpty ? _preset : _nameCtrl.text,
      icon: '📍',
      start: _startCtrl.text,
      end: _endCtrl.text,
      radius: _radius,
      colorHex: 0xFFF97316,
      active: true,
      inZone: true,
    );

    widget.onAddZone(zone);

    setState(() {
      _adding = false;
      _nameCtrl.clear();
      _startCtrl.clear();
      _endCtrl.clear();
    });
  }

  // ── Toggle In-Zone Status ─────────────────────
  void _toggleInZone(ZoneModel z) {
    z.inZone = !z.inZone;
    widget.onUpdateZone(z);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final ch = _child;

    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _adding
                        ? setState(() => _adding = false)
                        : widget.go('dashboard'),
                    child: Icon(Icons.arrow_back, color: T.text),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Safe Zones',
                    style: TextStyle(
                      color: T.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Zone List ───────────────────────────
            Expanded(
              child: _myZones.isEmpty
                  ? Center(
                      child: Text('No Safe Zones Yet',
                          style: TextStyle(color: T.sub)),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _myZones
                          .map((z) => _ZoneCard(
                                zone: z,
                                T: T,
                                onToggle: () {
                                  z.active = !z.active;
                                  widget.onUpdateZone(z);
                                  setState(() {});
                                },
                                onToggleInZone: () => _toggleInZone(z),
                                onDelete: () =>
                                    widget.onDeleteZone(z.id),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone Card with Status ─────────────────────
class _ZoneCard extends StatelessWidget {
  final ZoneModel zone;
  final AppTheme T;
  final VoidCallback onToggle;
  final VoidCallback onToggleInZone;
  final VoidCallback onDelete;

  const _ZoneCard({
    required this.zone,
    required this.T,
    required this.onToggle,
    required this.onToggleInZone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(zone.colorHex);

    final statusColor = zone.inZone ? Colors.green : Colors.red;
    final statusText =
        zone.inZone ? 'Child is SAFE ✅' : 'Child NOT in Zone ⚠️';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: zone.active
              ? statusColor.withOpacity(0.5)
              : T.border,
          width: zone.active ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [

          // ── Top Row ─────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(zone.icon)),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.name,
                        style: TextStyle(
                            color: T.text,
                            fontWeight: FontWeight.bold)),
                    Text('${zone.start} → ${zone.end}',
                        style: TextStyle(color: T.sub, fontSize: 12)),
                  ],
                ),
              ),

              Switch(
                value: zone.active,
                onChanged: (_) => onToggle(),
              ),

              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: T.red),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Status Box ──────────────────────
          GestureDetector(
            onTap: onToggleInZone,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, size: 10, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Radius: ${zone.radius}m',
              style: TextStyle(color: T.sub, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}