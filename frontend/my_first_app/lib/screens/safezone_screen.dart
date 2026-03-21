import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SafeZoneScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const SafeZoneScreen({
    super.key,
    required this.go,
    required this.T,
  });

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return Scaffold(
      backgroundColor: T.bg,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top Bar ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.go('dashboard'),
                    child: Icon(Icons.arrow_back, color: T.text),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safe Zones',
                        style: TextStyle(
                          color: T.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your child safe areas',
                        style: TextStyle(
                          color: T.sub,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body Placeholder ─────────────────────
            Expanded(
              child: Center(
                child: Text(
                  'No Safe Zones Yet',
                  style: TextStyle(
                    color: T.sub,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // ── Add Button ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  // will implement later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: T.cyan,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  '+ Add Zone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}