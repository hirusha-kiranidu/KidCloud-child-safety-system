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

  const OnboardScreen(
      {super.key, required this.idx, required this.go, required this.T});

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: i == idx ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == idx ? color : T.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            PrimaryBtn(
              label: idx < 2 ? 'Next →' : 'Get Started 🚀',
              onTap: () =>
                  go(idx < 2 ? 'onboard${idx + 1}' : 'welcome'),
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

  const WelcomeScreen({super.key, required this.go, required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.2,
          colors: [const Color(0xFF0A2448), T.bg],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 44, 24, 36),
        child: Column(
          children: [
            const Spacer(),

            const Text('👨‍👧‍👦', style: TextStyle(fontSize: 60)),

            const SizedBox(height: 18),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2),
                children: [
                  TextSpan(
                    text: 'Welcome to\n',
                    style: TextStyle(color: T.text),
                  ),
                  TextSpan(
                    text: 'KidCloud',
                    style: TextStyle(color: T.cyan),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Your child's safety, always in\n"
              "the palm of your hand.",
              textAlign: TextAlign.center,
              style: TextStyle(color: T.sub, fontSize: 14, height: 1.8),
            ),

            const SizedBox(height: 36),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final item in [
                  ['🔒', 'Secure'],
                  ['📍', 'Accurate'],
                  ['⚡', 'Real-Time']
                ]) ...[
                  Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: T.cyan.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: T.cyan.withOpacity(0.2)),
                        ),
                        child: Center(
                          child: Text(
                            item[0],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item[1],
                        style: TextStyle(
                          color: T.sub,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (item[0] != '⚡') const SizedBox(width: 24),
                ],
              ],
            ),

            const Spacer(),

            PrimaryBtn(
              label: 'Create Account',
              onTap: () => go('signup'),
              T: T,
            ),

            const SizedBox(height: 10),

            PrimaryBtn(
              label: 'Sign In',
              onTap: () => go('login'),
              T: T,
              outline: true,
            ),
          ],
        ),
      ),
    );
  }
}