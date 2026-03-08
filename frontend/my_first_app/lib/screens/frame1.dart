import 'package:flutter/material.dart';

class Frame1 extends StatelessWidget {
  const Frame1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9EC3D4),
              Color(0xFFBFDAD2),
              Color(0xFF9ED6B3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [

            const SizedBox(height: 120),

            // App Name
            const Text(
              "KIDCLOUD",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: Color(0xFFFF8C2B),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            const Text(
              "CARRY THEIR SAFETY, EVERYWHERE",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 4,
                color: Color(0xFF3A5A7A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}