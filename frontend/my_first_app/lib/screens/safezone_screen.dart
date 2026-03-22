import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';


class SafeZoneScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children;
  final List<ZoneModel>  zones;
  final Function(ZoneModel) onAddZone;
  final Function(ZoneModel) onUpdateZone;
  final Function(int)    onDeleteZone;
  final AppTheme T;

  const SafeZoneScreen({
    super.key,
    required this.go,
    required this.children,
    required this.zones,
    required this.onAddZone,
    required this.onUpdateZone,
    required this.onDeleteZone,
    required this.T,
  });

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {
  int    _childIdx  = 0;
  bool   _adding    = false;
  bool   _showAlert = false;
  String _alertZone = '';
  Timer? _alertTimer;

  final _nameCtrl  = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl   = TextEditingController();
  String _preset = 'Home';
  int    _radius = 200;

  final _presets = ['Home', 'School', 'Tuition', 'Playground', 'Park', 'Mall', 'Other'];
  final _radii   = [100, 200, 500, 1000];

  ChildModel? get _child =>
      widget.children.isEmpty ? null
      : widget.children[_childIdx.clamp(0, widget.children.length - 1)];

  List<ZoneModel> get _myZones =>
      _child == null ? [] : widget.zones.where((z) => z.childId == _child!.id).toList();

  @override
  void dispose() {
    _alertTimer?.cancel();
    _nameCtrl.dispose(); _startCtrl.dispose(); _endCtrl.dispose();
    super.dispose();
  }

  String _presetIcon(String p) {
    const icons = {'Home':'🏠','School':'🏫','Tuition':'📚','Playground':'🛝','Park':'🌳','Mall':'🛒'};
    return icons[p] ?? '📍';
  }

  int _presetColor(String p) {
    const colors = {'Home':0xFF22C55E,'School':0xFF3B82F6,'Tuition':0xFF8B5CF6,'Park':0xFF10B981,'Mall':0xFFF59E0B};
    return colors[p] ?? 0xFFF97316;
  }

  void _saveZone() {
    if (_child == null) return;
    if (_startCtrl.text.trim().isEmpty || _endCtrl.text.trim().isEmpty) return;

    final zone = ZoneModel(
      id:       DateTime.now().millisecondsSinceEpoch,
      childId:  _child!.id,
      name:     _nameCtrl.text.trim().isEmpty ? _preset : _nameCtrl.text.trim(),
      icon:     _presetIcon(_preset),
      start:    _startCtrl.text.trim(),
      end:      _endCtrl.text.trim(),
      radius:   _radius,
      colorHex: _presetColor(_preset),
      active:   true,
      inZone:   true,
    );
    widget.onAddZone(zone);   
    setState(() {
      _adding = false;
      _nameCtrl.clear(); _startCtrl.clear(); _endCtrl.clear();
      _preset = 'Home'; _radius = 200;
    });
  }

  void _toggleInZone(ZoneModel z) {
    final wasIn = z.inZone;
    z.inZone = !wasIn;
    widget.onUpdateZone(z);
    if (wasIn) {
      setState(() { _showAlert = true; _alertZone = z.name; });
      _alertTimer?.cancel();
      _alertTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showAlert = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final T  = widget.T;
    final ch = _child;

    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          KCTopBar(
            title: 'Safe Zones',
            sub: ch != null ? "${ch.name}'s zones (${_myZones.length})" : 'No children',
            onBack: () => _adding ? setState(() => _adding = false) : widget.go('dashboard'),
            T: T,
            rightEl: null,  
          ),

          if (ch == null) ...[
            const SizedBox(height: 40),
            Center(child: Column(children: [
              const Text('👶', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No children registered', style: TextStyle(color: T.text, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Add a child first.', style: TextStyle(color: T.sub, fontSize: 12)),
              const SizedBox(height: 20),
              PrimaryBtn(label: '➕ Add a Child', onTap: () => widget.go('addchild'), T: T),
            ])),
          ] else ...[

            
            if (widget.children.length > 1) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.children.asMap().entries.map((e) {
                    final sel = e.key == _childIdx;
                    final k   = e.value;
                    final kc  = Color(k.colorHex);
                    return GestureDetector(
                      onTap: () => setState(() { _childIdx = e.key; _adding = false; }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? kc.withOpacity(0.15) : T.card2,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: sel ? kc : T.border, width: sel ? 1.5 : 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(k.avatar, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(k.name, style: TextStyle(color: sel ? kc : T.sub, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],

            
            if (_adding)
              _AddZoneForm(
                T: T, childName: ch.name,
                nameCtrl: _nameCtrl, startCtrl: _startCtrl, endCtrl: _endCtrl,
                preset: _preset, radius: _radius, presets: _presets, radii: _radii,
                presetIcon: _presetIcon,
                onPreset: (p) => setState(() => _preset = p),
                onRadius: (r) => setState(() => _radius = r),
                onSave:   _saveZone,
                onCancel: () => setState(() => _adding = false),
              ),

            
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: T.cyan.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: T.cyan.withOpacity(0.2)),
              ),
              child: Row(children: [
                Icon(Icons.info_outline_rounded, color: T.cyan, size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Add safe zones from the Map screen using the location input at the top.',
                  style: TextStyle(color: T.sub, fontSize: 12, height: 1.4),
                )),
              ]),
            ),

            if (_myZones.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: T.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: T.border)),
                child: Column(children: [
                  const Text('🛡️', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 12),
                  Text('No Safe Zones Yet', style: TextStyle(color: T.text, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text("Tap \"+ Add Zone\" to create ${ch.name}'s first safe zone.\nZones also appear on the map.", style: TextStyle(color: T.sub, fontSize: 12, height: 1.6), textAlign: TextAlign.center),
                ]),
              )

            
            else if (_myZones.isNotEmpty) ...[
              
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: T.cyan.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: T.cyan.withOpacity(0.25))),
                child: Row(children: [
                  Icon(Icons.map_rounded, color: T.cyan, size: 16),
                  const SizedBox(width: 8),
                  Text('${_myZones.length} zone${_myZones.length > 1 ? 's' : ''} saved — visible on the map', style: TextStyle(color: T.cyan, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ),
              Text('ZONES (${_myZones.length})', style: TextStyle(color: T.sub, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 8),
              ..._myZones.map((z) => _ZoneCard(
                zone: z, T: T,
                onToggle: () { z.active = !z.active; widget.onUpdateZone(z); setState(() {}); },
                onToggleInZone: () => _toggleInZone(z),
                onDelete: () => widget.onDeleteZone(z.id),
              )),
            ],
          ],
        ]),
      ),

     
      if (_showAlert)
        Positioned(
          top: 12, left: 16, right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: widget.T.red,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: widget.T.red.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Row(children: [
                const Text('🚨', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_child?.name ?? 'Child'} left "$_alertZone"!', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                  const Text('Child is no longer in this safe zone', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ])),
                GestureDetector(onTap: () => setState(() => _showAlert = false), child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20)),
              ]),
            ),
          ),
        ),
    ]);
  }
}


class _ZoneCard extends StatelessWidget {
  final ZoneModel zone;
  final AppTheme T;
  final VoidCallback onToggle, onToggleInZone, onDelete;
  const _ZoneCard({required this.zone, required this.T, required this.onToggle, required this.onToggleInZone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color  = Color(zone.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: zone.active ? (zone.inZone ? T.green.withOpacity(0.4) : T.red.withOpacity(0.4)) : T.border,
          width: zone.active ? 1.5 : 1,
        ),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(zone.icon, style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(zone.name, style: TextStyle(color: T.text, fontSize: 14, fontWeight: FontWeight.w700)),
              Text('Radius: ${zone.radius}m', style: TextStyle(color: T.sub, fontSize: 11)),
            ])),
            Row(children: [
              KCToggle(on: zone.active, onToggle: onToggle, color: color, T: T),
              const SizedBox(width: 8),
              GestureDetector(onTap: onDelete, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: T.red.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: T.red.withOpacity(0.25))), child: Icon(Icons.delete_outline, color: T.red, size: 15))),
            ]),
          ]),
        ),
        if (zone.active) ...[
          Divider(height: 1, color: T.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(children: [
              Expanded(child: _PointTile(label: '🟢 Start', val: zone.start, T: T)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: _PointTile(label: '🔴 End', val: zone.end, T: T)),
            ]),
          ),
          Divider(height: 1, color: T.border),
          GestureDetector(
            onTap: onToggleInZone,
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: zone.inZone ? T.green.withOpacity(0.1) : T.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: zone.inZone ? T.green.withOpacity(0.4) : T.red.withOpacity(0.4)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: zone.inZone ? T.green : T.red, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(zone.inZone ? 'Child is SAFE ✅' : 'Child NOT in Zone ⚠️', style: TextStyle(color: zone.inZone ? T.green : T.red, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _PointTile extends StatelessWidget {
  final String label, val;
  final AppTheme T;
  const _PointTile({required this.label, required this.val, required this.T});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: T.card2, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: T.sub, fontSize: 9)),
        const SizedBox(height: 2),
        Text(val.isEmpty ? '—' : val, style: TextStyle(color: T.text, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      ]));
  }
}


class _AddZoneForm extends StatelessWidget {
  final AppTheme T;
  final String childName;
  final TextEditingController nameCtrl, startCtrl, endCtrl;
  final String preset;
  final int radius;
  final List<String> presets;
  final List<int> radii;
  final String Function(String) presetIcon;
  final Function(String) onPreset;
  final Function(int) onRadius;
  final VoidCallback onSave, onCancel;
  const _AddZoneForm({required this.T, required this.childName, required this.nameCtrl, required this.startCtrl, required this.endCtrl, required this.preset, required this.radius, required this.presets, required this.radii, required this.presetIcon, required this.onPreset, required this.onRadius, required this.onSave, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: T.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: T.cyan.withOpacity(0.3), width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: T.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(9)), child: Icon(Icons.shield_rounded, color: T.cyan, size: 17)),
          const SizedBox(width: 10),
          Text("Add Safe Zone for $childName", style: TextStyle(color: T.text, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        Text('ZONE TYPE', style: TextStyle(color: T.sub, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 6,
          children: presets.map((p) => GestureDetector(
            onTap: () => onPreset(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: preset == p ? T.cyan.withOpacity(0.12) : T.card2, borderRadius: BorderRadius.circular(20), border: Border.all(color: preset == p ? T.cyan : T.border, width: 1.5)),
              child: Text('${presetIcon(p)} $p', style: TextStyle(color: preset == p ? T.cyan : T.sub, fontSize: 12, fontWeight: preset == p ? FontWeight.w700 : FontWeight.w400)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 14),
        KCInput(label: 'Zone Name (optional)', placeholder: "e.g. Emma's School", icon: '🏷️', controller: nameCtrl, T: T),
        Text('ROUTE POINTS', style: TextStyle(color: T.sub, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        _RouteField(ctrl: startCtrl, label: 'Starting Point *', hint: 'e.g. Home address', dotColor: T.green, T: T),
        const SizedBox(height: 4),
        Padding(padding: const EdgeInsets.only(left: 5), child: Column(children: List.generate(3, (_) => Container(width: 2, height: 5, margin: const EdgeInsets.symmetric(vertical: 2), color: T.border)))),
        const SizedBox(height: 4),
        _RouteField(ctrl: endCtrl, label: 'Ending Point *', hint: 'e.g. School address', dotColor: T.red, T: T),
        const SizedBox(height: 14),
        Text('ALERT RADIUS', style: TextStyle(color: T.sub, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(children: radii.map((r) => Expanded(child: GestureDetector(
          onTap: () => onRadius(r),
          child: Container(
            margin: EdgeInsets.only(right: r != radii.last ? 7 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: radius == r ? T.cyan.withOpacity(0.12) : T.card2, borderRadius: BorderRadius.circular(10), border: Border.all(color: radius == r ? T.cyan : T.border, width: 1.5)),
            child: Text(r >= 1000 ? '${r ~/ 1000}km' : '${r}m', textAlign: TextAlign.center, style: TextStyle(color: radius == r ? T.cyan : T.sub, fontSize: 12, fontWeight: radius == r ? FontWeight.w700 : FontWeight.w400)),
          ),
        ))).toList()),
        const SizedBox(height: 6),
        Center(child: Text('Alert when child exits a ${radius >= 1000 ? '${radius ~/ 1000}km' : '${radius}m'} radius', style: TextStyle(color: T.muted, fontSize: 11))),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: PrimaryBtn(label: '🛡️ Save Zone', onTap: onSave, T: T)),
          const SizedBox(width: 8),
          Expanded(child: PrimaryBtn(label: 'Cancel', onTap: onCancel, T: T, ghost: true)),
        ]),
      ]),
    );
  }
}

class _RouteField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final Color dotColor;
  final AppTheme T;
  const _RouteField({required this.ctrl, required this.label, required this.hint, required this.dotColor, required this.T});
  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.15), width: 2))),
      const SizedBox(width: 12),
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: T.card2, borderRadius: BorderRadius.circular(12), border: Border.all(color: T.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: T.muted, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          TextField(controller: ctrl, style: TextStyle(color: T.text, fontSize: 13), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: T.muted, fontSize: 12), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero)),
        ]),
      )),
    ]);
  }
}