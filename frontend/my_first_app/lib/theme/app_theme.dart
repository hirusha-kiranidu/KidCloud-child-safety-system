import 'package:flutter/material.dart';

class AppTheme {
  final Color bgTop;
  final Color bgBottom;
  final Color border;
  final Color text;
  final Color sub;
  final Color cyan;
  final Color blue;

  // ✅ ADD THESE
  final Color bg;
  final Color card;

  AppTheme({
    required this.bgTop,
    required this.bgBottom,
    required this.border,
    required this.text,
    required this.sub,
    required this.cyan,
    required this.blue,
  })  : bg = bgBottom,
        card = bgBottom.withOpacity(0.1);
}
