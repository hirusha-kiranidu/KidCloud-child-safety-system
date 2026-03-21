import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';

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

          // ── Voice Detection ────────────────────
          _VoiceDetectionCard(T: T),

          const SizedBox(height: 12),

          // ── Live Location Card
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
                    child: const Center(
                      child: Text('📍', style: TextStyle(fontSize: 22)),
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

          const SizedBox(height: 20),

          // Placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.border),
            ),
            child: Text(
              'More features coming next...',
              style: TextStyle(color: T.text),
            ),
          ),
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
    final child = _selected;
    final childName = child?.name ?? 'Your Child';

    return Container(
      decoration: BoxDecoration(
        color: emergency
            ? (flash ? T.red.withOpacity(0.18) : T.red.withOpacity(0.08))
            : T.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emergency ? (flash ? T.red : T.red.withOpacity(0.5)) : T.green,
          width: emergency ? 2 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emergency
                        ? (flash ? T.red : T.red.withOpacity(0.3))
                        : T.green.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Text(
                      emergency ? '🆘' : '🛡️',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emergency
                        ? '$childName pressed the SOS button'
                        : 'No emergency detected',
                    style: TextStyle(color: emergency ? T.red : T.green),
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
          Expanded(
            child: Text(
              'Voice Detection Active',
              style: TextStyle(color: T.text),
            ),
          ),
        ],
      ),
    );
  }
}
