import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ Added Google Fonts
import '../theme/app_theme.dart'; // Keep this if you will use AppTheme later

class SplashScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const SplashScreen({super.key, required this.go, required this.T});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final nunitoFont = GoogleFonts.nunito().fontFamily; // Google Font

    return Scaffold(
      body: Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(
            fontSize: 24,
            fontFamily: nunitoFont, // Apply Nunito font
          ),
        ),
      ),
    );
  }
}