import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(const KidCloudApp());
}

class KidCloudApp extends StatelessWidget {
  const KidCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupScreen(),
    );
  }
}
