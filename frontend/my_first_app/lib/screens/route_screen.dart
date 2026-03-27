import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class RouteScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const RouteScreen({super.key, required this.go, required this.T});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  String _dateFilter = 'Today';

  final _timeline = const [
    {
      'time': '08:15 AM',
      'place': 'Left Home',
      'icon': '🏠',
      'colorHex': 0xFF22D67A,
      'dist': '—',
      'dur': '—'
    },
    {
      'time': '08:42 AM',
      'place': 'Arrived School',
      'icon': '🏫',
      'colorHex': 0xFF2B7EFF,
      'dist': '3.2km',
      'dur': '27min'
    },
    {
      'time': '12:30 PM',
      'place': 'School Cafe',
      'icon': '🍽️',
      'colorHex': 0xFFFF7D3E,
      'dist': '0.1km',
      'dur': '2min'
    },
    {
      'time': '03:10 PM',
      'place': 'Left School',
      'icon': '🚶',
      'colorHex': 0xFFFFD060,
      'dist': '—',
      'dur': '—'
    },
    {
      'time': '03:45 PM',
      'place': 'Arrived Home',
      'icon': '🏠',
      'colorHex': 0xFF22D67A,
      'dist': '3.2km',
      'dur': '35min'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KCTopBar(
              title: 'Route History',
              sub: 'Emma · Location trail',
              onBack: () => widget.go('dashboard'),
              T: T),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'Yesterday', 'This Week', 'Last Week']
                  .map((d) => GestureDetector(
                        onTap: () => setState(() => _dateFilter = d),
                        child: Container(
                          margin: const EdgeInsets.only(right: 7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 6),
                          decoration: BoxDecoration(
                            color: _dateFilter == d ? T.cyan : T.card2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _dateFilter == d ? T.cyan : T.border),
                          ),
                          child: Text(d,
                              style: TextStyle(
                                  color:
                                      _dateFilter == d ? Colors.black : T.sub,
                                  fontSize: 12,
                                  fontWeight: _dateFilter == d
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          MapPlaceholder(height: 160, showRoute: true, showZones: true, T: T),
          const SizedBox(height: 12),
          Row(children: [
            for (final s in [
              ['📍', '5 stops', 'Locations'],
              ['⏱️', '7h 30m', 'Out of Home'],
              ['📏', '6.5 km', 'Total Distance']
            ])
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: s[0] != '📏' ? 8 : 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: T.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: T.border)),
                  child: Column(children: [
                    Text(s[0], style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 3),
                    Text(s[1],
                        style: TextStyle(
                            color: T.cyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    Text(s[2], style: TextStyle(color: T.sub, fontSize: 9)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 16),
          Text('TIMELINE',
              style: TextStyle(
                  color: T.sub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 10),
          ...List.generate(_timeline.length, (i) {
            final r = _timeline[i];
            final color = Color(r['colorHex'] as int);
            final hasDistance = r['dist'] != '—';
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2)),
                    child: Center(
                        child: Text(r['icon'] as String,
                            style: const TextStyle(fontSize: 16))),
                  ),
                  if (i < _timeline.length - 1)
                    Container(width: 2, height: 32, color: T.border),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r['place'] as String,
                                style: TextStyle(
                                    color: T.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            Text(r['time'] as String,
                                style: TextStyle(color: T.sub, fontSize: 10)),
                          ],
                        ),
                        if (hasDistance) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            Pill(text: '📏 ${r['dist']}', color: T.blue),
                            const SizedBox(width: 8),
                            Pill(text: '⏱ ${r['dur']}', color: T.indigo),
                          ]),
                        ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
