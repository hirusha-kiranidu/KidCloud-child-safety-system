import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Back Button ─────────────────────────────────────
class KCBackBtn extends StatelessWidget {
  final VoidCallback onTap;
  final AppTheme T;

  const KCBackBtn({Key? key, required this.onTap, required this.T})
    : super(key: key);

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

// ── Top Bar ─────────────────────────────────────────
class KCTopBar extends StatelessWidget {
  final String title;
  final String? sub;
  final VoidCallback? onBack;
  final Widget? rightEl;
  final AppTheme T;

  const KCTopBar({
    Key? key,
    required this.title,
    this.sub,
    this.onBack,
    this.rightEl,
    required this.T,
  }) : super(key: key);

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
