import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class TrackingScreen extends StatelessWidget {
  final ChildModel? child;
  final Function(String) go;
  final AppTheme T;

  const TrackingScreen({
    super.key,
    this.child,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    final c = child ?? kidsData[0];
    final color = Color(c.colorHex);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          KCTopBar(
            title: 'Live Tracking',
            sub: 'Real-time GPS · Updated just now',
            onBack: () => go('dashboard'),
            T: T,
            rightEl: Pill(text: '${c.avatar} ${c.name}', color: color),
          ),
        ],
      ),
    );
  }
}
