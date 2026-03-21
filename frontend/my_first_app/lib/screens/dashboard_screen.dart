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
  bool _emergency = false;
  int? _selectedChildId;

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
          // ── Header ─────────────────────────────
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
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: T.card2,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Text('🔔', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── SOS CARD ───────────────────────────
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

          // ── Voice Detection ───────
          _VoiceDetectionCard(T: T),

          const SizedBox(height: 12),

          // ── Live Location ─────
          GestureDetector(
            onTap: () => widget.go('map'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.cyan.withOpacity(0.35), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${widget.children.where((c) => c.online).length} of ${widget.children.length} children tracked',
                      style: TextStyle(color: T.text),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── MY CHILDREN
          Text(
            'MY CHILDREN',
            style: TextStyle(
              color: T.sub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          ...widget.children.map(
            (child) => GestureDetector(
              onTap: () {
                widget.setChild(child);
                widget.go('tracking');
              },
              child: _ChildCard(child: child, T: T),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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
          // Top Row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    child.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${child.name} · ${child.age}y',
                      style: TextStyle(
                        color: T.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '● ${child.status}',
                      style: TextStyle(color: color, fontSize: 12),
                    ),
                    Text(
                      child.school,
                      style: TextStyle(color: T.sub, fontSize: 10),
                    ),
                  ],
                ),
              ),

              BatteryWidget(pct: child.battery, T: T),
            ],
          ),

          const SizedBox(height: 10),

          // Mini Stats
          Row(
            children: [
              _MiniStat(
                val: child.online ? 'Active' : 'Offline',
                label: 'Status',
                T: T,
              ),
              _MiniStat(val: '${child.battery}%', label: 'Battery', T: T),
              _MiniStat(val: child.device, label: 'Device', T: T),
            ],
          ),
        ],
      ),
    );
  }
}

// Mini Stat Widget
class _MiniStat extends StatelessWidget {
  final String val, label;
  final AppTheme T;

  const _MiniStat({required this.val, required this.label, required this.T});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: T.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: TextStyle(color: T.sub, fontSize: 9)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.border),
      ),
      child: Row(
        children: [
          const Text('🎙️', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text('Voice Detection Active', style: TextStyle(color: T.text)),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emergency ? T.red.withOpacity(0.1) : T.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emergency ? '🆘 SOS Alert' : '🛡️ All Safe'),
          const Spacer(),
          GestureDetector(
            onTap: onTest,
            child: Text(emergency ? 'ALERT' : 'SAFE'),
          ),
        ],
      ),
    );
  }
}
