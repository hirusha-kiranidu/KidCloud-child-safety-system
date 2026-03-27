import 'package:flutter/material.dart';

class AppTheme {
  final Color bg;
  final Color surface;
  final Color card;
  final Color card2;
  final Color border;
  final Color text;
  final Color sub;
  final Color muted;
  final Color cyan;
  final Color cyanD;
  final Color blue;
  final Color indigo;
  final Color green;
  final Color red;
  final Color orange;
  final Color yellow;
  final Color pink;

  const AppTheme({
    required this.bg,
    required this.surface,
    required this.card,
    required this.card2,
    required this.border,
    required this.text,
    required this.sub,
    required this.muted,
    required this.cyan,
    required this.cyanD,
    required this.blue,
    required this.indigo,
    required this.green,
    required this.red,
    required this.orange,
    required this.yellow,
    required this.pink,
  });
}

final darkTheme = AppTheme(
  bg: const Color(0xFF0B1120),
  surface: const Color(0xFF0F1829).withOpacity(0.75),
  card: const Color(0xFF172030).withOpacity(0.65),
  card2: const Color(0xFFFFFFFF).withOpacity(0.06),
  border: const Color(0xFFFFFFFF).withOpacity(0.12),
  text: const Color(0xFFEFF6FF),
  sub: const Color(0xFF94A8C0),
  muted: const Color(0xFF4A637F),
  cyan: const Color(0xFFF97316),
  cyanD: const Color(0xFFDC6910),
  blue: const Color(0xFF60A5FA),
  indigo: const Color(0xFF818CF8),
  green: const Color(0xFF34D399),
  red: const Color(0xFFF87171),
  orange: const Color(0xFFFBBF24),
  yellow: const Color(0xFFFCD34D),
  pink: const Color(0xFFF9A8D4),
);

final lightTheme = AppTheme(
  bg: const Color(0xFFE8F4FF),
  surface: const Color(0xFFFFFFFF).withOpacity(0.85),
  card: const Color(0xFFFFFFFF).withOpacity(0.75),
  card2: const Color(0xFFFFFFFF).withOpacity(0.55),
  border: const Color(0xFF000000).withOpacity(0.08),
  text: const Color(0xFF0A1628),
  sub: const Color(0xFF3A5A7A),
  muted: const Color(0xFF8BAABB),
  cyan: const Color(0xFFEA580C),
  cyanD: const Color(0xFFCC4F0A),
  blue: const Color(0xFF1D6FBF),
  indigo: const Color(0xFF4338CA),
  green: const Color(0xFF15803D),
  red: const Color(0xFFB91C1C),
  orange: const Color(0xFFB45309),
  yellow: const Color(0xFF92400E),
  pink: const Color(0xFF9D174D),
);
