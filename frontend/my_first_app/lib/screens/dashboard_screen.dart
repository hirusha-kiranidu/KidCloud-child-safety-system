import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';

class DashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                onTap: () => go('notifs'),
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

          const SizedBox(height: 20),

          // ── Placeholder Content ──────────────────────────
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
                  'Dashboard Content Coming Soon',
                  style: TextStyle(
                    color: T.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This is the base layout (Commit 1)',
                  style: TextStyle(color: T.sub, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
