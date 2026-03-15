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

          MapPlaceholder(height: 200, showRoute: true, showZones: true, T: T),

          const SizedBox(height: 12),

          Row(
            children: kidsData.map((k) {
              final kc = Color(k.colorHex);
              final isSelected = k.id == c.id;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: k.id == kidsData.first.id ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kc.withOpacity(0.11) : T.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? kc : T.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(k.avatar, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            k.name,
                            style: TextStyle(
                              color: T.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '● ${k.status}',
                            style: TextStyle(color: kc, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
