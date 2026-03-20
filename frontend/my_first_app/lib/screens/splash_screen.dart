import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const SplashScreen({super.key, required this.go, required this.T});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = Tween<double>(begin: 0, end: 1).animate(_ctrl);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 10000), () {
      if (mounted) widget.go('onboard0');
    });  
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 0.9,
            colors: [const Color(0xFF0A2448), T.bg],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Logo ──────────────────────────────────────
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 22),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1),
                children: [
                  TextSpan(
                      text: 'Kid', style: TextStyle(color: T.text)),
                  TextSpan(
                      text: 'Cloud', style: TextStyle(color: T.cyan)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Carry Their Safety, Everywhere',
                style: TextStyle(
                    color: T.sub, fontSize: 13, letterSpacing: 0.5)),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin:
                            const EdgeInsets.symmetric(horizontal: 3.5),
                        width: i == 0 ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == 0 ? T.cyan : T.muted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }
}
