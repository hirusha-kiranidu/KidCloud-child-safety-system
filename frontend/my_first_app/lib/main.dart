import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';
import 'screens/safe_zone_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String screen = "splash";

  void go(String nextScreen) {
    setState(() {
      screen = nextScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final T = AppTheme(
      bgTop: Colors.blue.shade900,
      bgBottom: Colors.blue.shade400,
      border: Colors.grey,
      text: Colors.white,
      sub: Colors.white70,
      cyan: Colors.cyan,
      blue: Colors.blue,
      card: Colors.white,    // added card color
    );

    // Sample children for SafeZoneScreen
    final children = [
      ChildModel(id: 1, name: 'Emma', avatar: '👧', colorHex: 0xFF3B82F6),
      ChildModel(id: 2, name: 'Liam', avatar: '👦', colorHex: 0xFF22C55E),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: buildScreen(T, children),
        ),
      ),
    );
  }

  Widget buildScreen(AppTheme T, List<ChildModel> children) {
    switch (screen) {
      case "splash":
        return SplashScreen(go: go, T: T);

      case "onboard0":
        return OnboardScreen(idx: 0, go: go, T: T);

      case "onboard1":
        return OnboardScreen(idx: 1, go: go, T: T);

      case "onboard2":
        return OnboardScreen(idx: 2, go: go, T: T);

      case "safezone":
        return SafeZoneScreen(go: go, T: T, children: children);

      default:
        return SplashScreen(go: go, T: T);
    }
  }
}

// Dummy ChildModel for demonstration (replace with your real models.dart)
class ChildModel {
  final int id;
  final String name;
  final String avatar;
  final int colorHex;

  ChildModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.colorHex,
  });
}