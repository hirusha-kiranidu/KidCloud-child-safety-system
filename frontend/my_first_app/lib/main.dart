import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';
import 'screens/auth_screen.dart'; // AUTH SCREEN IMPORT
import 'screens/dashboard_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/notifs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/safezone_screen.dart';

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
    final T = AppTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SafeArea(child: buildScreen(T))),
    );
  }

  Widget buildScreen(AppTheme T) {
    switch (screen) {
      case "signup":
        return SignupScreen(go: go, T: T);
      case "login":
        return LoginScreen(go: go, T: T);
      default:
        // You can replace this with a fallback widget or throw if appropriate
        return const SizedBox.shrink();
    }
  }
}
