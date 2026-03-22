import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

//Primary Button 
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppTheme T;
  final bool outline;
  final bool ghost;
  final bool danger;
  final bool soft;

  const PrimaryBtn({
    Key? key,
    required this.label,
    required this.onTap,
    required this.T,
    this.outline = false,
    this.ghost = false,
    this.danger = false,
    this.soft = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Decoration decoration;
    Color textColor;

    if (danger) {
      decoration = BoxDecoration(
        gradient: LinearGradient(colors: [T.red, const Color(0xFFB01838)]),
        borderRadius: BorderRadius.circular(14),
      );
      textColor = Colors.white;
    } else if (outline) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.cyan, width: 2),
      );
      textColor = T.cyan;
    } else if (ghost) {
      decoration = BoxDecoration(
        color: T.card2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.border, width: 1.5),
      );
      textColor = T.text;
    } else if (soft) {
      decoration = BoxDecoration(
        color: T.cyan.withOpacity(0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: T.cyan.withOpacity(0.25), width: 1.5),
      );
      textColor = T.cyan;
    } else {
      decoration = BoxDecoration(
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
        decoration: decoration,
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
