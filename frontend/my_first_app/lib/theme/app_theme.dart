import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════
//  KIDCLOUD BRAND COLOR SYSTEM  v2
//
//  Dark mode: Navy #0B1120 background, strong contrast
//  Light mode: Sky blue #E8F4FF background (website color)
//  Primary: KidCloud Orange #F97316
// ════════════════════════════════════════════════════════

class AppTheme {
  final Color bg;
  final Color surface;
  final Color card;
  final Color card2;
  final Color border;
  final Color text;
  final Color sub;
  final Color muted;
  final Color cyan; // brand primary (orange)
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

// ── DARK THEME ────────────────────────────────────────────
// Rich navy with high-contrast orange accents and glass transparency
final darkTheme = AppTheme(
  bg: const Color(0xFF0B1120),
  surface: const Color(0xFF0F1829).withOpacity(0.75), // nav bar, headers
  card: const Color(0xFF172030).withOpacity(0.65), // card backgrounds
  card2: const Color(0xFFFFFFFF).withOpacity(0.06), // secondary cards
  border: const Color(0xFFFFFFFF).withOpacity(0.12), // visible borders
  text: const Color(0xFFEFF6FF), // near-white, high contrast
  sub: const Color(0xFF94A8C0), // subtitles — brighter than before
  muted: const Color(0xFF4A637F), // muted labels
  cyan: const Color(0xFFF97316), // KidCloud orange (primary)
  cyanD: const Color(0xFFDC6910),
  blue: const Color(0xFF60A5FA), // lighter blue for dark bg
  indigo: const Color(0xFF818CF8),
  green: const Color(0xFF34D399), // bright green for dark bg
  red: const Color(0xFFF87171), // bright red for dark bg
  orange: const Color(0xFFFBBF24), // amber gold accent
  yellow: const Color(0xFFFCD34D),
  pink: const Color(0xFFF9A8D4),
);

// ── LIGHT THEME ───────────────────────────────────────────
// Sky-blue background matching kid-cloud.com website with glass transparency
final lightTheme = AppTheme(
  bg: const Color(0xFFE8F4FF), // website sky blue
  surface: const Color(0xFFFFFFFF).withOpacity(0.85),
  card: const Color(0xFFFFFFFF).withOpacity(0.75),
  card2: const Color(0xFFFFFFFF).withOpacity(0.55), // slightly deeper sky blue
  border: const Color(0xFF000000).withOpacity(0.08),
  text: const Color(0xFF0A1628),
  sub: const Color(0xFF3A5A7A),
  muted: const Color(0xFF8BAABB),
  cyan: const Color(0xFFEA580C), // darker orange for readability
  cyanD: const Color(0xFFCC4F0A),
  blue: const Color(0xFF1D6FBF),
  indigo: const Color(0xFF4338CA),
  green: const Color(0xFF15803D),
  red: const Color(0xFFB91C1C),
  orange: const Color(0xFFB45309),
  yellow: const Color(0xFF92400E),
  pink: const Color(0xFF9D174D),
);
