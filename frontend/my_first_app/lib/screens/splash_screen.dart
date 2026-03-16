import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Google Fonts
import '../theme/app_theme.dart'; // AppTheme

class SplashScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const SplashScreen({
    super.key,
    required this.go,
    required this.T,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Text(
          'Splash Screen',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: T.cyan,
          ),
        ),
      ),
    );
  }
}