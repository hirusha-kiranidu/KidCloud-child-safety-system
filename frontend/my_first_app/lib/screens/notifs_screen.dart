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

    return Container();
  }
}
