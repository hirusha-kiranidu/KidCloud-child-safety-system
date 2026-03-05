import 'package:flutter/material.dart';

// Import your 5 onboarding screens
import 'screens/frame1.dart';
import 'screens/frame2.dart';
import 'screens/frame3.dart';
import 'screens/frame4.dart';
import 'screens/frame5.dart';

void main() {
  runApp(const KidCloudApp());
}

class KidCloudApp extends StatelessWidget {
  const KidCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KidCloud Onboarding',

      initialRoute: '/',

      routes: {
        '/': (context) => const Frame1(),
        '/frame2': (context) => const Frame2(),
        '/frame3': (context) => const Frame3(),
        '/frame4': (context) => const Frame4(),
        '/frame5': (context) => const Frame5(),
      },

      theme: ThemeData(
        primaryColor: const Color(0xFF00C2E0),
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}