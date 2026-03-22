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

          // Placeholder for emergency contacts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.border),
            ),
            child: Text(
              'Emergency contacts will appear here',
              style: TextStyle(color: T.sub, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
