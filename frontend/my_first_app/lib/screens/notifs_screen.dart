import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotifsScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const NotifsScreen({super.key, required this.go, required this.T});

  @override
  State<NotifsScreen> createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsScreen> {
  String _filter = 'All';

  final _notifs = const [
    {
      'id': 1,
      'icon': '🚨',
      'title': 'Voice Alert',
      'desc': 'Voice distress detected near School',
      'time': '5m ago',
      'urgent': true,
      'colorHex': 0xFFFF3E5E,
      'child': 'Emma',
    },
    {
      'id': 2,
      'icon': '📍',
      'title': 'Left Safe Zone',
      'desc': 'Leo left the School safe zone',
      'time': '12m ago',
      'urgent': true,
      'colorHex': 0xFFFF7D3E,
      'child': 'Leo',
    },
    {
      'id': 3,
      'icon': '✅',
      'title': 'Emma arrived at School',
      'desc': 'Emma entered School safe zone',
      'time': '1h ago',
      'urgent': false,
      'colorHex': 0xFF22D67A,
      'child': 'Emma',
    },
    {
      'id': 4,
      'icon': '⚠️',
      'title': 'Unusual Route',
      'desc': 'Liam taking an unexpected route home',
      'time': '2h ago',
      'urgent': true,
      'colorHex': 0xFFFFD060,
      'child': 'Liam',
    },
    {
      'id': 5,
      'icon': '🔋',
      'title': 'Low Battery (18%)',
      'desc': "Emma's band battery is critical",
      'time': '3h ago',
      'urgent': false,
      'colorHex': 0xFFFFD060,
      'child': 'Emma',
    },
    {
      'id': 6,
      'icon': '🏃',
      'title': 'Activity Goal!',
      'desc': 'Liam hit 5,000 steps today 🎉',
      'time': '5h ago',
      'urgent': false,
      'colorHex': 0xFF6366F1,
      'child': 'Liam',
    },
    {
      'id': 7,
      'icon': '⌚',
      'title': 'Band Reconnected',
      'desc': "Emma's band is back online",
      'time': '6h ago',
      'urgent': false,
      'colorHex': 0xFF00E5C8,
      'child': 'Emma',
    },
    {
      'id': 8,
      'icon': '📊',
      'title': 'Weekly Summary',
      'desc': "View this week's activity & location report",
      'time': '1d ago',
      'urgent': false,
      'colorHex': 0xFF2B7EFF,
      'child': 'All',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    final cats = ['All', 'Urgent', 'Emma', 'Liam'];

    final filtered = _filter == 'All'
        ? _notifs
        : _filter == 'Urgent'
        ? _notifs.where((n) => n['urgent'] == true).toList()
        : _notifs.where((n) => n['child'] == _filter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      color: T.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_notifs.where((n) => n['urgent'] == true).length} urgent · Today',
                    style: TextStyle(color: T.sub, fontSize: 11),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => widget.go('alerthistory'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: T.blue.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.blue),
                  ),
                  child: Text(
                    '📋 History',
                    style: TextStyle(
                      color: T.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cats.map((c) {
                return GestureDetector(
                  onTap: () => setState(() => _filter = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _filter == c ? T.cyan : T.card2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _filter == c ? T.cyan : T.border,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color: _filter == c ? Colors.black : T.sub,
                        fontSize: 12,
                        fontWeight: _filter == c
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          ...filtered.map((n) {
            final color = Color(n['colorHex'] as int);
            final isUrgent = n['urgent'] as bool;

            return GestureDetector(
              onTap: isUrgent ? () => widget.go('voice_alert') : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUrgent ? color.withOpacity(0.33) : T.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          n['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n['title'] as String,
                            style: TextStyle(
                              color: isUrgent ? color : T.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            n['desc'] as String,
                            style: TextStyle(color: T.sub, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          n['time'] as String,
                          style: TextStyle(color: T.muted, fontSize: 10),
                        ),
                        if (isUrgent) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Alert History Screen ─────────────────────────────
class AlertHistoryScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const AlertHistoryScreen({super.key, required this.go, required this.T});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  String _filter = 'This Week';

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
