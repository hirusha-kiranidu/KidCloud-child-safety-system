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
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Pulsing animation timer
    _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) {
        setState(() => _flash = !_flash);
      }
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
          //  Header
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

          // SOS ALERT CARD
          _EmergencyAlertCard(
            emergency: _emergency,
            flash: _flash,
            children: widget.children,
            onTest: () => setState(() => _emergency = !_emergency),
            T: T,
          ),

          const SizedBox(height: 20),

          // Placeholder (rest of dashboard comes later)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.border),
            ),
            child: Column(
              children: [
                Text(
                  'More features coming in next commits...',
                  style: TextStyle(
                    color: T.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

//  EMERGENCY ALERT CARD

class _EmergencyAlertCard extends StatelessWidget {
  final bool emergency;
  final bool flash;
  final List<ChildModel> children;
  final VoidCallback onTest;
  final AppTheme T;

  const _EmergencyAlertCard({
    required this.emergency,
    required this.flash,
    required this.children,
    required this.onTest,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    final childName = children.isNotEmpty ? children.first.name : 'Your Child';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emergency
            ? (flash ? T.red.withOpacity(0.18) : T.red.withOpacity(0.08))
            : T.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: emergency ? T.red : T.green, width: 1.5),
      ),
      child: Row(
        children: [
          // ── Icon ──────
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

          // ── Text ──
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

          // ── Demo Toggle Button ────
          GestureDetector(
            onTap: onTest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
    );
  }
}
