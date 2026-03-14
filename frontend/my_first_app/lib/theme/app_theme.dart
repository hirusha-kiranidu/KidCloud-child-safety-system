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
  bg: const Color(0xFF07090F),
  surface: const Color(0xFF0D1520),
  card: const Color(0xFF111D2E),
  card2: const Color(0xFF182438),
  border: const Color(0xFF1E2F48),
  text: const Color(0xFFEEF4FF),
  sub: const Color(0xFF6B85A8),
  muted: const Color(0xFF2E4060),
  cyan: const Color(0xFF00E5C8),
  cyanD: const Color(0xFF00B09E),
  blue: const Color(0xFF2B7EFF),
  indigo: const Color(0xFF6366F1),
  green: const Color(0xFF22D67A),
  red: const Color(0xFFFF3E5E),
  orange: const Color(0xFFFF7D3E),
  yellow: const Color(0xFFFFD060),
  pink: const Color(0xFFFF6EB4),
);

final lightTheme = AppTheme(
  bg: const Color(0xFFF0F4FA),
  surface: const Color(0xFFFFFFFF),
  card: const Color(0xFFFFFFFF),
  card2: const Color(0xFFEBF0FA),
  border: const Color(0xFFD5E0F0),
  text: const Color(0xFF0D1828),
  sub: const Color(0xFF5A708A),
  muted: const Color(0xFFB8CADA),
  cyan: const Color(0xFF0096A0),
  cyanD: const Color(0xFF007880),
  blue: const Color(0xFF1A5FD4),
  indigo: const Color(0xFF4F46E5),
  green: const Color(0xFF16A85E),
  red: const Color(0xFFE02050),
  orange: const Color(0xFFD9620A),
  yellow: const Color(0xFFC49200),
  pink: const Color(0xFFC0308A),
);
