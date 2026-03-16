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
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1,
          colors: [color.withOpacity(0.1), T.bg],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => go('login'),
                child: Text(
                  'Skip →',
                  style: TextStyle(color: T.sub, fontSize: 13),
                ),
              ),
            ),

            const Spacer(),

            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: color.withOpacity(0.27), width: 2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.13), blurRadius: 70)
                ],
              ),
              child: Center(
                child: Text(
                  data['icon'] as String,
                  style: const TextStyle(fontSize: 66),
                ),
              ),
            ),

            const SizedBox(height: 34),

            Text(
              data['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: T.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              data['desc'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: T.sub,
                fontSize: 14,
                height: 1.75,
              ),
            ),

            const Spacer(),

            PrimaryBtn(
              label: 'Next →',
              onTap: () => go('onboard${idx + 1}'),
              T: T,
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