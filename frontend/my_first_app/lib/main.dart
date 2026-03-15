import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';

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
      home: Scaffold(
        body: SafeArea(
          child: buildScreen(T),
        ),
      ),
    );
  }

  Widget buildScreen(AppTheme T) {

    switch (screen) {

      case "splash":
        return SplashScreen(go: go, T: T);

      case "onboard0":
        return OnboardScreen(idx: 0, go: go, T: T);

      case "onboard1":
        return OnboardScreen(idx: 1, go: go, T: T);

      case "onboard2":
        return OnboardScreen(idx: 2, go: go, T: T);

      case "welcome":
        return WelcomeScreen(go: go, T: T);

      default:
        return SplashScreen(go: go, T: T);
    }
  }
}

