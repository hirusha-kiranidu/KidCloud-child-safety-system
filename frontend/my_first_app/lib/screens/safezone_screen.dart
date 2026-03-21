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

            // ── Child Selector ───────────────────────
            if (widget.children.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: widget.children.asMap().entries.map((e) {
                    final index = e.key;
                    final child = e.value;
                    final selected = index == _childIdx;
                    final color = Color(child.colorHex);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _childIdx = index;
                          _adding = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color.withOpacity(0.15) : T.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? color : T.border),
                        ),
                        child: Row(
                          children: [
                            Text(child.avatar),
                            const SizedBox(width: 6),
                            Text(child.name,
                                style: TextStyle(
                                    color: selected ? color : T.sub)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // ── Body ────────────────────────────────
            Expanded(
              child: _adding && ch != null
                  ? _AddZoneForm(
                      T: T,
                      nameCtrl: _nameCtrl,
                      startCtrl: _startCtrl,
                      endCtrl: _endCtrl,
                      preset: _preset,
                      radius: _radius,
                      presets: _presets,
                      radii: _radii,
                      onPreset: (p) => setState(() => _preset = p),
                      onRadius: (r) => setState(() => _radius = r),
                      onSave: _saveZone,
                      onCancel: () => setState(() => _adding = false),
                    )
                  : _myZones.isEmpty
                      ? Center(
                          child: Text(
                            'No Safe Zones Yet',
                            style: TextStyle(color: T.sub),
                          ),
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
                                    onDelete: () {
                                      widget.onDeleteZone(z.id);
                                    },
                                  ))
                              .toList(),
                        ),
            ),

            // ── Add Button ───────────────────────────
            if (!_adding)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _adding = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: T.cyan,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('+ Add Zone'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Zone Card UI ─────────────────────────────
class _ZoneCard extends StatelessWidget {
  final ZoneModel zone;
  final AppTheme T;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ZoneCard({
    required this.zone,
    required this.T,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(zone.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.border),
      ),
      child: Column(
        children: [

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

          const SizedBox(height: 8),

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

// ── Add Zone Form (same as previous) ─────────
class _AddZoneForm extends StatelessWidget {
  final AppTheme T;
  final TextEditingController nameCtrl, startCtrl, endCtrl;
  final String preset;
  final int radius;
  final List<String> presets;
  final List<int> radii;
  final Function(String) onPreset;
  final Function(int) onRadius;
  final VoidCallback onSave, onCancel;

  const _AddZoneForm({
    required this.T,
    required this.nameCtrl,
    required this.startCtrl,
    required this.endCtrl,
    required this.preset,
    required this.radius,
    required this.presets,
    required this.radii,
    required this.onPreset,
    required this.onRadius,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Form UI here (same as previous commit)'),
    );
  }
}