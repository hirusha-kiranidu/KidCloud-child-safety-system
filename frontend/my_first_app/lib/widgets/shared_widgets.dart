import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Battery Widget ──────────────────────────────────
class BatteryWidget extends StatelessWidget {
  final int pct;
  final AppTheme T;

  const BatteryWidget({Key? key, required this.pct, required this.T})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = pct > 50
        ? T.green
        : pct > 20
        ? T.yellow
        : T.red;

    return Row(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 22,
              height: 11,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.all(1),
              child: FractionallySizedBox(
                widthFactor: pct / 100,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -4,
              child: Container(
                width: 3,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Text(
          '$pct%',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Map Placeholder ─────────────────────────────────
class MapPlaceholder extends StatelessWidget {
  final double height;
  final bool showRoute;
  final bool showZones;
  final AppTheme T;

  const MapPlaceholder({
    Key? key,
    this.height = 200,
    this.showRoute = false,
    this.showZones = false,
    required this.T,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF091422),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, height),
            painter: MapPainter(
              showRoute: showRoute,
              showZones: showZones,
              height: height,
            ),
          ),

          // LIVE badge
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00E5C8).withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00E5C8).withOpacity(0.27),
                ),
              ),
              child: const Text(
                '● LIVE MAP',
                style: TextStyle(
                  color: Color(0xFF00E5C8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Powered by GPS',
                style: TextStyle(color: T.sub, fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map Painter ─────────────────────────────────────
class MapPainter extends CustomPainter {
  final bool showRoute;
  final bool showZones;
  final double height;

  MapPainter({
    required this.showRoute,
    required this.showZones,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF0E2440)
      ..strokeWidth = 12;

    final thinRoad = Paint()
      ..color = const Color(0xFF0E2440)
      ..strokeWidth = 7;

    final blockPaint = Paint()..color = const Color(0xFF0C1C30);

    final routePaint = Paint()
      ..color = const Color(0xFF00E5C8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final zonePaint = Paint()
      ..color = const Color(0xFF22D67A).withOpacity(0.12);

    final zoneBorderPaint = Paint()
      ..color = const Color(0xFF22D67A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bluePaint = Paint()
      ..color = const Color(0xFF2B7EFF).withOpacity(0.12);

    final blueBorderPaint = Paint()
      ..color = const Color(0xFF2B7EFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final childPaint = Paint()..color = const Color(0xFF00E5C8);

    final childRingPaint = Paint()
      ..color = const Color(0xFF00E5C8).withOpacity(0.13);

    // Roads
    canvas.drawLine(
      Offset(0, height * 0.5),
      Offset(size.width, height * 0.5),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, height * 0.25),
      Offset(size.width, height * 0.25),
      thinRoad,
    );
    canvas.drawLine(
      Offset(0, height * 0.75),
      Offset(size.width, height * 0.75),
      thinRoad,
    );

    canvas.drawLine(Offset(85, 0), Offset(85, height), thinRoad);
    canvas.drawLine(Offset(170, 0), Offset(170, height), roadPaint);
    canvas.drawLine(Offset(255, 0), Offset(255, height), thinRoad);

    // Zones
    if (showZones) {
      canvas.drawCircle(Offset(42, height * 0.78), 30, zonePaint);
      canvas.drawCircle(Offset(42, height * 0.78), 30, zoneBorderPaint);
      canvas.drawCircle(Offset(240, height * 0.22), 34, bluePaint);
      canvas.drawCircle(Offset(240, height * 0.22), 34, blueBorderPaint);
    }

    // Route
    if (showRoute) {
      final path = Path()
        ..moveTo(42, height * 0.78)
        ..lineTo(85, height * 0.5)
        ..lineTo(170, height * 0.5)
        ..lineTo(240, height * 0.22);

      canvas.drawPath(path, routePaint);
    }

    // Child position
    canvas.drawCircle(Offset(160, height * 0.5), 18, childRingPaint);
    canvas.drawCircle(Offset(160, height * 0.5), 10, childPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
