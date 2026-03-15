import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}