import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Input Field ─────────────────────────────────────
class KCInput extends StatelessWidget {
  final String? label;
  final String placeholder;
  final String icon;
  final bool obscure;
  final TextEditingController? controller;
  final AppTheme T;
  final TextInputType? keyboardType;

  const KCInput({
    Key? key,
    this.label,
    required this.placeholder,
    required this.icon,
    this.obscure = false,
    this.controller,
    required this.T,
    this.keyboardType,
  }) : super(key: key);

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

// ── Toggle Switch ───────────────────────────────────
class KCToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onToggle;
  final Color? color;
  final AppTheme T;

  const KCToggle({
    Key? key,
    required this.on,
    required this.onToggle,
    this.color,
    required this.T,
  }) : super(key: key);

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
