import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';

class SafeZoneScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  final List<ChildModel> children;

  const SafeZoneScreen({
    super.key,
    required this.go,
    required this.T,
    required this.children,
  });

  @override
  State<SafeZoneScreen> createState() => _SafeZoneScreenState();
}

class _SafeZoneScreenState extends State<SafeZoneScreen> {

  int _childIdx = 0;

  ChildModel? get _child =>
      widget.children.isEmpty
          ? null
          : widget.children[_childIdx.clamp(0, widget.children.length - 1)];

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final ch = _child;

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
                        ch != null
                            ? "${ch.name}'s zones"
                            : 'No children',
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

            // ── Child Selector ───────────────────────
            if (widget.children.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: widget.children.asMap().entries.map((e) {
                    final index = e.key;
                    final child = e.value;
                    final selected = index == _childIdx;

                    final color = Color(child.colorHex);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _childIdx = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.15)
                              : T.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? color : T.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(child.avatar,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              child.name,
                              style: TextStyle(
                                color: selected ? color : T.sub,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // ── Body Placeholder ─────────────────────
            Expanded(
              child: Center(
                child: Text(
                  ch == null
                      ? 'No children registered'
                      : 'No Safe Zones Yet',
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