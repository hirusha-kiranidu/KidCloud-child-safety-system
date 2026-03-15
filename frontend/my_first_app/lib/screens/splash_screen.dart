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

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final nunitoFont = GoogleFonts.nunito().fontFamily;

    return Scaffold(
      body: Center(
        child: Text(
          'KidCloud',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: nunitoFont,
            color: T.cyan,
          ),
        ),
      ),
    );
  }
}