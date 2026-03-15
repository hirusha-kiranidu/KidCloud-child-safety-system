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

          // Child Switcher
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

          // Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${c.avatar} ${c.name}'s Location",
                      style: TextStyle(
                        color: T.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Pill(text: '● LIVE', color: T.green),
                  ],
                ),

                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                  children: [
                    _InfoTile(
                      label: 'Zone',
                      val: c.status,
                      color: T.green,
                      T: T,
                    ),
                    _InfoTile(
                      label: 'Speed',
                      val: '0.0 km/h',
                      color: T.blue,
                      T: T,
                    ),
                    _InfoTile(
                      label: 'Lat',
                      val: '3.139°N',
                      color: T.cyan,
                      T: T,
                    ),
                    _InfoTile(
                      label: 'Lng',
                      val: '101.686°E',
                      color: T.cyan,
                      T: T,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryBtn(
                        label: '📍 Navigate',
                        onTap: () {},
                        T: T,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: PrimaryBtn(
                        label: '🗓 History',
                        onTap: () => go('route'),
                        T: T,
                        ghost: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, val;
  final Color color;
  final AppTheme T;

  const _InfoTile({
    required this.label,
    required this.val,
    required this.color,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: T.card2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: T.sub, fontSize: 10)),
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
