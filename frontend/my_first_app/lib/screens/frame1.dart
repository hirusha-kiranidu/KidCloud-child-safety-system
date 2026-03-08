import 'package:flutter/material.dart';

class Frame1 extends StatelessWidget {
  const Frame1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        // Background Gradient
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 120),

            // KIDCLOUD Title
            const Text(
              "KIDCLOUD",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                letterSpacing: 6,
                color: Color(0xFFFF8C2B),
              ),
            ),

            const SizedBox(height: 12),

            // Tagline Text
            const Text(
              "CARRY THEIR SAFETY, EVERYWHERE",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 4,
                color: Color.fromARGB(255, 71, 124, 181), // Blue color
                fontWeight: FontWeight.bold, // Bold text
              ),
            ),
          ],
        ),
      ),
    );
  }
}