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
  const DashboardScreen({
    super.key,
    required this.go,
    required this.setChild,
    required this.children,
    required this.T,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _flash = false;
  bool _emergency = false; // true = SOS pressed on wristband
  int? _selectedChildId; // which child the SOS alert is for
  late Timer _timer;

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

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Parent Dashboard',
                style: TextStyle(
                  color: T.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: () => widget.go('notifs'),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: T.card2,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Text('🔔', style: TextStyle(fontSize: 20)),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: T.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: T.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _EmergencyAlertCard(
            emergency: _emergency,
            flash: _flash,
            children: widget.children,
            selectedChildId: _selectedChildId,
            onSelectChild: (id) => setState(() => _selectedChildId = id),
            onDismiss: () => setState(() => _emergency = false),
            onTest: () => setState(() => _emergency = !_emergency),
            T: T,
          ),
          const SizedBox(height: 12),

          // ── Voice Detection (simplified, no premium/toggle) ──
          _VoiceDetectionCard(T: T),
          const SizedBox(height: 12),

          // ── Live Location card only ───────────────────────
          GestureDetector(
            onTap: () => widget.go('map'),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.cyan.withOpacity(0.35), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: T.cyan.withOpacity(0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('📍', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Location',
                          style: TextStyle(
                            color: T.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${widget.children.where((c) => c.online).length} of ${widget.children.length} children tracked',
                          style: TextStyle(color: T.sub, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: T.cyan,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── My Children ───────────────────────────────────
          Text(
            'MY CHILDREN',
            style: TextStyle(
              color: T.sub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          ...widget.children.map(
            (k) => GestureDetector(
              onTap: () {
                widget.setChild(k);
                widget.go('tracking');
              },
              child: _ChildCard(child: k, T: T),
            ),
          ),

          // ── Quick Actions ─────────────────────────────────
          const SizedBox(height: 6),
          Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: T.sub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
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
                  T: T,
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────

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
        border: Border.all(color: T.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                ),
                child: Center(
                  child: Text(
                    child.avatar,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: child.name,
                            style: TextStyle(
                              color: T.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' · ${child.age}y',
                            style: TextStyle(
                              color: T.sub,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '● ${child.status}',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${child.last} · ${child.school}',
                      style: TextStyle(color: T.sub, fontSize: 10),
                    ),
                  ],
                ),
              ),
              BatteryWidget(pct: child.battery, T: T),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                val: child.online ? 'Active' : 'Offline',
                label: 'Status',
                icon: child.online ? '🟢' : '⚫',
                color: child.online ? T.green : T.muted,
                T: T,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                val: '${child.battery}%',
                label: 'Battery',
                icon: '🔋',
                color: T.indigo,
                T: T,
              ),
              const SizedBox(width: 8),
              _MiniStat(
                val: child.device,
                label: 'Device',
                icon: '⌚',
                color: T.sub,
                T: T,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String val, label, icon;
  final Color color;
  final AppTheme T;
  const _MiniStat({
    required this.val,
    required this.label,
    required this.icon,
    required this.color,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: T.card2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: TextStyle(color: T.muted, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final AppTheme T;
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: T.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: T.cyan.withOpacity(0.07),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: T.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyAlertCard extends StatelessWidget {
  final bool emergency;
  final bool flash;
  final List<ChildModel> children;
  final int? selectedChildId;
  final Function(int) onSelectChild;
  final VoidCallback onDismiss;
  final VoidCallback onTest;
  final AppTheme T;
  const _EmergencyAlertCard({
    required this.emergency,
    required this.flash,
    required this.children,
    required this.selectedChildId,
    required this.onSelectChild,
    required this.onDismiss,
    required this.onTest,
    required this.T,
  });

  ChildModel? get _selected {
    if (children.isEmpty) return null;
    if (selectedChildId == null) return children.first;
    return children.firstWhere(
      (c) => c.id == selectedChildId,
      orElse: () => children.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final T = this.T;
    final child = _selected;
    final childName = child?.name ?? 'Your Child';

    return Container(
      decoration: BoxDecoration(
        color: emergency
            ? (flash ? T.red.withOpacity(0.18) : T.red.withOpacity(0.09))
            : T.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emergency
              ? (flash ? T.red : T.red.withOpacity(0.5))
              : T.green.withOpacity(0.4),
          width: emergency ? 2 : 1.5,
        ),
        boxShadow: emergency && flash
            ? [
                BoxShadow(
                  color: T.red.withOpacity(0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: "SOS Alert" title + child selector ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emergency
                        ? (flash ? T.red : T.red.withOpacity(0.25))
                        : T.green.withOpacity(0.15),
                    border: Border.all(
                      color: emergency ? T.red : T.green,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emergency ? '🆘' : '🛡️',
                      style: TextStyle(fontSize: emergency && flash ? 20 : 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOS Alert',
                        style: TextStyle(
                          color: emergency ? T.red : T.green,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        emergency
                            ? '$childName pressed the SOS button on wristband'
                            : 'No emergency detected · All clear',
                        style: TextStyle(
                          color: emergency
                              ? T.red.withOpacity(0.75)
                              : T.green.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Demo toggle button
                GestureDetector(
                  onTap: onTest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: emergency
                          ? T.red.withOpacity(0.12)
                          : T.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: emergency
                            ? T.red.withOpacity(0.4)
                            : T.green.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      emergency ? '● ALERT' : '✔ SAFE',
                      style: TextStyle(
                        color: emergency ? T.red : T.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Child selector row ───────────────────────────
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.child_care_rounded,
                    color: emergency
                        ? T.red.withOpacity(0.6)
                        : T.green.withOpacity(0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Select child:',
                    style: TextStyle(
                      color: T.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: children.map((ch) {
                          final isSel =
                              (selectedChildId ?? children.first.id) == ch.id;
                          final kc = Color(ch.colorHex);
                          return GestureDetector(
                            onTap: () => onSelectChild(ch.id),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSel ? kc.withOpacity(0.15) : T.card2,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSel ? kc : T.border,
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    ch.avatar,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    ch.name,
                                    style: TextStyle(
                                      color: isSel ? kc : T.sub,
                                      fontSize: 11,
                                      fontWeight: isSel
                                          ? FontWeight.w700
                                          : FontWeight.w400,
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
                ],
              ),
            ),

          // ── Action buttons (only shown during emergency) ──
          if (emergency)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: T.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Mark as Resolved',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, color: T.red, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Call 119',
                            style: TextStyle(
                              color: T.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
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
        border: Border.all(color: T.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: T.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: T.cyan.withOpacity(0.3)),
            ),
            child: const Center(
              child: Text('🎙️', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Detection',
                  style: TextStyle(
                    color: T.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Wristband mic monitors for distress keywords',
                  style: TextStyle(color: T.sub, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: T.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: T.green.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: T.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Active',
                  style: TextStyle(
                    color: T.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
