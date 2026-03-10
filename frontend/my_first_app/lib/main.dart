import 'package:flutter/material.dart';

void main() {
  runApp(const KidCloudApp());
}

class KidCloudApp extends StatelessWidget {
  const KidCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text("KidCloud"))),
    );
  }
}
