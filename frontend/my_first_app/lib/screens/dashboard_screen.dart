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
            onDismiss: () => setState(() => _emergency = false), // NEW
            onTest: () => setState(() => _emergency = !_emergency),
            T: T,
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
  final VoidCallback onDismiss; // NEW
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
            ? (flash ? T.red.withOpacity(0.18) : T.red.withOpacity(0.08))
            : T.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: emergency ? (flash ? T.red : T.red.withOpacity(0.5)) : T.green,
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
          // ── Header ─────────────────────────────
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
                    border: Border.all(
                      color: emergency ? T.red : T.green,
                      width: 2,
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emergency ? 'SOS Alert' : 'All Safe',
                        style: TextStyle(
                          color: emergency ? T.red : T.green,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        emergency
                            ? '$childName pressed the SOS button'
                            : 'No emergency detected',
                        style: TextStyle(
                          color: emergency ? T.red : T.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onTest,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: emergency
                          ? T.red.withOpacity(0.15)
                          : T.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      emergency ? 'ALERT' : 'SAFE',
                      style: TextStyle(
                        color: emergency ? T.red : T.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Child Selector ─────────────────────
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: children.map((ch) {
                    final isSelected =
                        (selectedChildId ?? children.first.id) == ch.id;
                    final color = Color(ch.colorHex);

                    return GestureDetector(
                      onTap: () => onSelectChild(ch.id),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.15) : T.card2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : T.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              ch.avatar,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ch.name,
                              style: TextStyle(
                                color: isSelected ? color : T.sub,
                                fontSize: 11,
                                fontWeight: isSelected
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

          // ── Emergency Actions (NEW - Commit 4) ──
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
                              Icons.check_circle_outline,
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
                          Icon(Icons.phone, color: T.red, size: 16),
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
