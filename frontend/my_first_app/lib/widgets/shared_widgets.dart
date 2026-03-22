import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pill Badge
class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

//  Primary Button
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppTheme T;
  final bool outline;
  final bool ghost;
  final bool danger;
  final bool soft;
  const PrimaryBtn({
    super.key,
    required this.label,
    required this.onTap,
    required this.T,
    this.outline = false,
    this.ghost = false,
    this.danger = false,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    Decoration deco;
    Color textColor;
    if (danger) {
      deco = BoxDecoration(
        gradient: LinearGradient(colors: [T.red, const Color(0xFFB01838)]),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = Colors.white;
    } else if (outline) {
      deco = BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.cyan, width: 2),
      );
      textColor = T.cyan;
    } else if (ghost) {
      deco = BoxDecoration(
        color: T.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.border, width: 1.5),
      );
      textColor = T.text;
    } else if (soft) {
      deco = BoxDecoration(
        color: T.cyan.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.cyan.withOpacity(0.25), width: 1.5),
      );
      textColor = T.cyan;
    } else {
      deco = BoxDecoration(
        gradient: LinearGradient(
          colors: [T.cyan, T.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: deco,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// Labeled Input
class KCInput extends StatelessWidget {
  final String? label;
  final String placeholder;
  final String icon;
  final bool obscure;
  final TextEditingController? controller;
  final AppTheme T;
  final TextInputType? keyboardType;

  const KCInput({
    super.key,
    this.label,
    required this.placeholder,
    required this.icon,
    this.obscure = false,
    this.controller,
    required this.T,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: T.sub,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Container(
          decoration: BoxDecoration(
            color: T.card2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: T.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: TextStyle(color: T.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: T.muted),
              prefixText: '$icon  ',
              prefixStyle: const TextStyle(fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// Toggle Switch
class KCToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onToggle;
  final Color? color;
  final AppTheme T;
  const KCToggle({
    super.key,
    required this.on,
    required this.onToggle,
    this.color,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: on ? (color ?? T.cyan) : T.muted,
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Back Button
class KCBackBtn extends StatelessWidget {
  final VoidCallback onTap;
  final AppTheme T;
  const KCBackBtn({super.key, required this.onTap, required this.T});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: T.card2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: T.border),
        ),
        child: Icon(Icons.chevron_left, color: T.text, size: 22),
      ),
    );
  }
}

// Top Bar
class KCTopBar extends StatelessWidget {
  final String title;
  final String? sub;
  final VoidCallback? onBack;
  final Widget? rightEl;
  final AppTheme T;
  const KCTopBar({
    super.key,
    required this.title,
    this.sub,
    this.onBack,
    this.rightEl,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          if (onBack != null) ...[
            KCBackBtn(onTap: onBack!, T: T),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: T.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (sub != null)
                  Text(sub!, style: TextStyle(color: T.sub, fontSize: 11)),
              ],
            ),
          ),
          if (rightEl != null) rightEl!,
        ],
      ),
    );
  }
}

//Battery Widget
class BatteryWidget extends StatelessWidget {
  final int pct;
  final AppTheme T;
  const BatteryWidget({super.key, required this.pct, required this.T});

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

// Map Placeholder
class MapPlaceholder extends StatelessWidget {
  final double height;
  final bool showRoute;
  final bool showZones;
  final AppTheme T;
  const MapPlaceholder({
    super.key,
    this.height = 200,
    this.showRoute = false,
    this.showZones = false,
    required this.T,
  });

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
      ..color = const Color(0xFF22D67A).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final zoneBorderPaint = Paint()
      ..color = const Color(0xFF22D67A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final bluePaint = Paint()
      ..color = const Color(0xFF2B7EFF).withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final blueBorderPaint = Paint()
      ..color = const Color(0xFF2B7EFF)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final childPaint = Paint()
      ..color = const Color(0xFF00E5C8)
      ..style = PaintingStyle.fill;
    final childRingPaint = Paint()
      ..color = const Color(0xFF00E5C8).withOpacity(0.13)
      ..style = PaintingStyle.fill;

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
    canvas.drawLine(
      Offset(170, 0),
      Offset(170, height),
      roadPaint..strokeWidth = 12,
    );
    canvas.drawLine(Offset(255, 0), Offset(255, height), thinRoad);

    // Blocks
    final rrect = (Rect r) =>
        RRect.fromRectAndRadius(r, const Radius.circular(5));
    canvas.drawRRect(rrect(Rect.fromLTWH(8, 8, 68, height * 0.18)), blockPaint);
    canvas.drawRRect(
      rrect(Rect.fromLTWH(96, 8, 65, height * 0.18)),
      blockPaint,
    );
    canvas.drawRRect(
      rrect(Rect.fromLTWH(178, 8, 65, height * 0.18)),
      blockPaint,
    );
    canvas.drawRRect(
      rrect(Rect.fromLTWH(268, 8, 60, height * 0.18)),
      blockPaint,
    );
    canvas.drawRRect(
      rrect(Rect.fromLTWH(8, height * 0.3, 68, height * 0.15)),
      blockPaint,
    );
    canvas.drawRRect(
      rrect(Rect.fromLTWH(96, height * 0.3, 65, height * 0.15)),
      blockPaint,
    );
    canvas.drawRRect(
      rrect(Rect.fromLTWH(268, height * 0.55, 60, height * 0.18)),
      blockPaint,
    );

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
      routePaint.strokeWidth = 2.5;
      canvas.drawPath(path, routePaint);
      // Endpoints
      for (final pt in [
        Offset(42, height * 0.78),
        Offset(240, height * 0.22),
      ]) {
        canvas.drawCircle(
          pt,
          11,
          Paint()
            ..color = const Color(0xFF00E5C8).withOpacity(0.31)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pt,
          6,
          Paint()
            ..color = const Color(0xFF00E5C8)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Child dot
    canvas.drawCircle(Offset(160, height * 0.5), 18, childRingPaint);
    canvas.drawCircle(Offset(160, height * 0.5), 10, childPaint);

    final textPainter = TextPainter(
      text: const TextSpan(text: '👧', style: TextStyle(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(155, height * 0.5 - 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
