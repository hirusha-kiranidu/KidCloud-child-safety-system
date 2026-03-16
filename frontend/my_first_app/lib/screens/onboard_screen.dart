import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

const _obData = [
  {
    'icon': '📡',
    'title': 'Real-Time GPS Tracking',
    'desc':
        'Know exactly where your child is — every second of every day with live GPS updates and location history.',
    'color': 0xFF00E5C8,
  },
  {
    'icon': '🛡️',
    'title': 'Safe Zone Alerts',
    'desc':
        'Draw custom zones around home, school, and more. Get instant alerts the moment your child crosses a boundary.',
    'color': 0xFF22D67A,
  },
  {
    'icon': '⌚',
    'title': 'Smart Wristband',
    'desc':
        'The KidCloud band tracks steps, heart rate, sleep, and sends a one-press SOS signal directly to you.',
    'color': 0xFF6366F1,
  },
];

class OnboardScreen extends StatelessWidget {
  final int idx;
  final Function(String) go;
  final AppTheme T;

  const OnboardScreen({
    super.key,
    required this.idx,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    final data = _obData[idx];
    final color = Color(data['color'] as int);

    return Container(
      color: T.bg,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['icon'] as String,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 20),
            Text(
              data['title'] as String,
              style: TextStyle(
                color: T.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                data['desc'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(color: T.sub, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final Function(String) go;
  final AppTheme T;

  const WelcomeScreen({
    super.key,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text("Welcome Screen"),
      ),
    );
  }
}