import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  final Function(String) go;
  final Function(ChildModel) setChild;
  final List<ChildModel> children;
  final AppTheme T;
  const DashboardScreen(
      {super.key,
      required this.go,
      required this.setChild,
      required this.children,
      required this.T});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _flash = false;
  late Timer _timer;

  Map<int, bool> _emergencies = {};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _flash = !_flash);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool get _anyEmergency => _emergencies.values.any((v) => v);

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Parent Dashboard',
                  style: TextStyle(
                      color: T.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => widget.go('notifs'),
                child: Stack(children: [
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: T.card2,
                          borderRadius: BorderRadius.circular(13)),
                      child: const Text('🔔', style: TextStyle(fontSize: 20))),
                  Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                              color: T.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: T.surface, width: 2)))),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!_anyEmergency)
            _SOSSafeCard(
              T: T,
              onSimulate: () {
                if (widget.children.isNotEmpty) {
                  setState(() {
                    final id = widget.children.first.id;
                    _emergencies[id] = !(_emergencies[id] ?? false);
                  });
                }
              },
            )
          else
            Column(
              children: widget.children
                  .where((ch) => _emergencies[ch.id] == true)
                  .map((ch) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _SOSAlertCard(
                          child: ch,
                          flash: _flash,
                          T: T,
                          onDismiss: () =>
                              setState(() => _emergencies[ch.id] = false),
                        ),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 12),
          _VoiceDetectionCard(T: T),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => widget.go('map'),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.cyan.withOpacity(0.35), width: 1.5),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: T.cyan.withOpacity(0.13), shape: BoxShape.circle),
                  child: const Center(
                      child: Text('📍', style: TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Live Location',
                          style: TextStyle(
                              color: T.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(
                          '${widget.children.where((c) => c.online).length} of ${widget.children.length} children tracked',
                          style: TextStyle(color: T.sub, fontSize: 11)),
                    ])),
                Icon(Icons.arrow_forward_ios_rounded, color: T.cyan, size: 16),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('MY CHILDREN',
              style: TextStyle(
                  color: T.sub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          ...widget.children.map((k) => _ChildCard(child: k, T: T)),
          const SizedBox(height: 6),
          Text('QUICK ACTIONS',
              style: TextStyle(
                  color: T.sub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 9,
            mainAxisSpacing: 9,
            childAspectRatio: 2.8,
            children: [
              for (final item in [
                ['➕', 'Add Child', 'addchild'],
                ['👶', 'Manage Children', 'managechild'],
                ['🛡️', 'Safe Zones', 'safezone'],
                ['📞', 'Emergency', 'emergency'],
                ['🗓️', 'Route History', 'route'],
              ])
                _QuickActionBtn(
                    icon: item[0],
                    label: item[1],
                    onTap: () => widget.go(item[2]),
                    T: T),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SOSSafeCard extends StatelessWidget {
  final AppTheme T;
  final VoidCallback onSimulate;
  const _SOSSafeCard({required this.T, required this.onSimulate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: T.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.green.withOpacity(0.4), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: T.green.withOpacity(0.15),
              border: Border.all(color: T.green, width: 2)),
          child:
              const Center(child: Text('🛡️', style: TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('SOS Alert',
              style: TextStyle(
                  color: T.green, fontSize: 15, fontWeight: FontWeight.w900)),
          Text('No emergency detected · All clear',
              style: TextStyle(color: T.green.withOpacity(0.8), fontSize: 11)),
        ])),
        GestureDetector(
          onTap: onSimulate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: T.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: T.green.withOpacity(0.4)),
            ),
            child: Text('✔ SAFE',
                style: TextStyle(
                    color: T.green, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}

class _SOSAlertCard extends StatelessWidget {
  final ChildModel child;
  final bool flash;
  final AppTheme T;
  final VoidCallback onDismiss;
  const _SOSAlertCard(
      {required this.child,
      required this.flash,
      required this.T,
      required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final T = this.T;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: flash ? T.red.withOpacity(0.18) : T.red.withOpacity(0.09),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: flash ? T.red : T.red.withOpacity(0.5), width: 2),
        boxShadow: flash
            ? [
                BoxShadow(
                    color: T.red.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(children: [
            // Child avatar (pulsing)
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: flash ? T.red : T.red.withOpacity(0.25),
                border: Border.all(color: T.red, width: 2.5),
              ),
              child: Center(
                  child:
                      Text(child.avatar, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('SOS Alert — ${child.name}',
                      style: TextStyle(
                          color: T.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2)),
                  Text('${child.name} pressed the SOS button on wristband',
                      style: TextStyle(
                          color: T.red.withOpacity(0.75), fontSize: 11)),
                ])),
            // Pulsing indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: flash ? T.red : Colors.transparent,
                border: Border.all(color: T.red, width: 2),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: T.red, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Mark as Resolved',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: T.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: T.red.withOpacity(0.4)),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.phone_rounded, color: T.red, size: 16),
                  const SizedBox(width: 6),
                  Text('Call 119',
                      style: TextStyle(
                          color: T.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Child card — NO tap navigation ────────────────────────
class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final AppTheme T;
  const _ChildCard({required this.child, required this.T});

  @override
  Widget build(BuildContext context) {
    final color = Color(child.colorHex);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: T.border)),
      child: Column(children: [
        Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.5)),
            child: Center(
                child:
                    Text(child.avatar, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: child.name,
                      style: TextStyle(
                          color: T.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' · ${child.age}y',
                      style: TextStyle(color: T.sub, fontSize: 11)),
                ])),
                Text('● ${child.status}',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text('${child.last} · ${child.school}',
                    style: TextStyle(color: T.sub, fontSize: 10)),
              ])),
          BatteryWidget(pct: child.battery, T: T),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _MiniStat(
              val: child.online ? 'Active' : 'Offline',
              label: 'Status',
              icon: child.online ? '🟢' : '⚫',
              color: child.online ? T.green : T.muted,
              T: T),
          const SizedBox(width: 8),
          _MiniStat(
              val: '${child.battery}%',
              label: 'Battery',
              icon: '🔋',
              color: T.indigo,
              T: T),
          const SizedBox(width: 8),
          _MiniStat(
              val: child.device,
              label: 'Device',
              icon: '⌚',
              color: T.sub,
              T: T),
        ]),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String val, label, icon;
  final Color color;
  final AppTheme T;
  const _MiniStat(
      {required this.val,
      required this.label,
      required this.icon,
      required this.color,
      required this.T});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
            color: T.card2, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(color: T.muted, fontSize: 9)),
        ]),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final AppTheme T;
  const _QuickActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.T});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: T.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: T.border)),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: T.cyan.withOpacity(0.07),
                borderRadius: BorderRadius.circular(9)),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 8),
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: T.text, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }
}

class _VoiceDetectionCard extends StatelessWidget {
  final AppTheme T;
  const _VoiceDetectionCard({required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: T.border)),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: T.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: T.cyan.withOpacity(0.3))),
          child:
              const Center(child: Text('🎙️', style: TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Voice Detection',
              style: TextStyle(
                  color: T.text, fontSize: 14, fontWeight: FontWeight.w700)),
          Text('Wristband mic monitors for distress keywords',
              style: TextStyle(color: T.sub, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
              color: T.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: T.green.withOpacity(0.35))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: T.green, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text('Active',
                style: TextStyle(
                    color: T.green, fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
        ),
      ]),
    );
  }
}
