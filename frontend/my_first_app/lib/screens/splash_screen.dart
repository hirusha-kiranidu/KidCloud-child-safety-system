import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
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
    final nunitoFont = GoogleFonts.nunito().fontFamily;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [T.bgTop, T.bgBottom],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [T.cyan, T.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(
                  child: Text('☁️', style: TextStyle(fontSize: 50)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  fontFamily: nunitoFont,
                ),
                children: [
                  TextSpan(text: 'Kid', style: TextStyle(color: T.text)),
                  TextSpan(text: 'Cloud', style: TextStyle(color: T.cyan)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}