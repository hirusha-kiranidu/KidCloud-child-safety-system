import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class EmergencyScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children;
  final AppTheme T;

  const EmergencyScreen({
    super.key,
    required this.go,
    required this.children,
    required this.T,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          // Top bar with back navigation and '+ Add' toggle
          KCTopBar(
            title: 'Emergency Contacts',
            sub: 'SOS alert recipients',
            onBack: () => widget.go('dashboard'),
            T: T,
            rightEl: GestureDetector(
              onTap: () => setState(() => _adding = !_adding),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: T.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.red),
                ),
                child: Text(
                  '+ Add',
                  style: TextStyle(
                    color: T.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Info banner ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: T.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: T.orange.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These contacts are notified when an SOS alert is triggered. Police (119) is always included.',
                    style: TextStyle(color: T.sub, fontSize: 11, height: 1.65),
                  ),
                ),
              ],
            ),
          ),

          // ── Pinned: Police Emergency ──────────────────
          Text(
            'EMERGENCY SERVICES',
            style: TextStyle(
              color: T.sub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _EmergencyContactCard(
            avatar: '👮',
            name: 'Police Emergency',
            role: 'Emergency Services',
            phone: '119',
            color: T.red,
            pinned: true,
            T: T,
          ),
        ],
      ),
    );
  }
}

// ── Emergency contact card ───────────────────────
class _EmergencyContactCard extends StatelessWidget {
  final String avatar, name, role, phone;
  final Color color;
  final bool pinned;
  final AppTheme T;

  const _EmergencyContactCard({
    required this.avatar,
    required this.name,
    required this.role,
    required this.phone,
    required this.color,
    required this.pinned,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pinned ? color.withOpacity(0.4) : T.border,
          width: pinned ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35), width: 2),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: T.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (pinned) ...[
                      const SizedBox(width: 6),
                      Pill(text: 'Always', color: T.red),
                    ],
                  ],
                ),
                Text(role, style: TextStyle(color: T.sub, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
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
