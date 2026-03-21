import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';

class SafeZoneScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  final List<ChildModel> children;

  const SafeZoneScreen({
    super.key,
    required this.go,
    required this.T,
    required this.children,
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
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
                          border: Border.all(
                            color: selected ? color : T.border,
                          ),
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

            // ── Add Zone Form ────────────────────────
            if (_adding && ch != null)
              Expanded(
                child: _AddZoneForm(
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
                  onCancel: () => setState(() => _adding = false),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    ch == null
                        ? 'No children registered'
                        : 'No Safe Zones Yet',
                    style: TextStyle(color: T.sub),
                  ),
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

// ── Add Zone Form UI ─────────────────────────────
class _AddZoneForm extends StatelessWidget {
  final AppTheme T;
  final TextEditingController nameCtrl, startCtrl, endCtrl;
  final String preset;
  final int radius;
  final List<String> presets;
  final List<int> radii;
  final Function(String) onPreset;
  final Function(int) onRadius;
  final VoidCallback onCancel;

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
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text('Zone Type', style: TextStyle(color: T.sub)),

          Wrap(
            spacing: 8,
            children: presets.map((p) {
              final selected = p == preset;
              return GestureDetector(
                onTap: () => onPreset(p),
                child: Chip(
                  label: Text(p),
                  backgroundColor:
                      selected ? T.cyan.withOpacity(0.2) : T.card,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Zone Name'),
          ),

          TextField(
            controller: startCtrl,
            decoration: const InputDecoration(labelText: 'Start Location'),
          ),

          TextField(
            controller: endCtrl,
            decoration: const InputDecoration(labelText: 'End Location'),
          ),

          const SizedBox(height: 16),

          Text('Radius', style: TextStyle(color: T.sub)),

          Row(
            children: radii.map((r) {
              final selected = r == radius;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onRadius(r),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? T.cyan.withOpacity(0.2)
                          : T.card,
                    ),
                    child: Center(child: Text('${r}m')),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {}, // save later
            child: const Text('Save Zone'),
          ),

          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}