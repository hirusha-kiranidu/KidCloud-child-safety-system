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
    final T = AppTheme(
      bg: Colors.white,
      surface: Colors.grey[50]!,
      card: Colors.white,
      card2: Colors.grey[100]!,
      border: Colors.grey[300]!,
      text: Colors.black,
      sub: Colors.grey[700]!,
      muted: Colors.grey[500]!,
      cyan: Colors.cyan,
      cyanD: Colors.cyan[700]!,
      blue: Colors.blue,
      indigo: Colors.indigo,
      green: Colors.green,
      red: Colors.red,
      orange: Colors.orange,
      yellow: Colors.yellow,
      pink: Colors.pink,
    );

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
      // ...other cases if needed...
    }
    // Default fallback if no case matches
    return Center(
      child: Text(
        'Unknown screen: '
        '"[screen]"',
      ),
    );
  }
}