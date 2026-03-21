import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class TrackingScreen extends StatefulWidget {
  final ChildModel? child;
  final List<ChildModel> children;
  final List<ZoneModel> zones;
  final Function(ZoneModel) onAddZone; // saves zone to main.dart
  final Function(String) go;
  final AppTheme T;
  const TrackingScreen({
    super.key,
    this.child,
    required this.children,
    required this.zones,
    required this.onAddZone,
    required this.go,
    required this.T,
  });

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late ChildModel? _selected;
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;
  bool _showRoute = false;
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  bool _routeSaved = false;

  // Zones for currently selected child
  List<ZoneModel> get _myZones => _selected == null
      ? []
      : widget.zones.where((z) => z.childId == _selected!.id).toList();

  @override
  void initState() {
    super.initState();
    _selected =
        widget.child ??
        (widget.children.isNotEmpty ? widget.children.first : null);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    if (widget.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'No Children Added',
              style: TextStyle(
                color: T.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a child to start live tracking.',
              style: TextStyle(color: T.sub, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryBtn(
              label: '➕ Add a Child',
              onTap: () => widget.go('addchild'),
              T: T,
            ),
          ],
        ),
      );
    }

    if (_selected == null ||
        !widget.children.any((c) => c.id == _selected!.id)) {
      _selected = widget.children.first;
    }

    final c = _selected!;
    final color = Color(c.colorHex);

    return Column(
      children: [
        // ─ select child
        Container(
          color: T.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => widget.go('dashboard'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: T.card2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.border),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: T.text,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.children.asMap().entries.map((e) {
                      final k = e.value;
                      final kc = Color(k.colorHex);
                      final sel = k.id == c.id;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selected = k;
                          _routeSaved = false;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: e.key < widget.children.length - 1 ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? kc.withOpacity(0.15) : T.card2,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: sel ? kc : T.border,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                k.avatar,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    k.name,
                                    style: TextStyle(
                                      color: sel ? kc : T.text,
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: k.online ? T.green : T.muted,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        k.online ? 'Online' : 'Offline',
                                        style: TextStyle(
                                          color: k.online ? T.green : T.muted,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─Full map
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: ValueKey(
                      'map_${c.id}_${_myZones.length}_${_myZones.map((z) => z.id).join('_')}',
                    ),
                    painter: _SriLankaMap(
                      childColor: color,
                      childName: c.name,
                      childAvatar: c.avatar,
                      zones: _myZones,
                    ),
                  ),
                ),
              ),

              // Search bar
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _searchActive = true;
                    _showRoute = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: _searchActive
                          ? Colors.white
                          : Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _searchActive
                            ? color
                            : Colors.white.withOpacity(0.18),
                        width: _searchActive ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: _searchActive ? color : Colors.white70,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _searchActive
                              ? TextField(
                                  controller: _searchCtrl,
                                  autofocus: true,
                                  style: const TextStyle(
                                    color: Color(0xFF0A1628),
                                    fontSize: 14,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search location in Sri Lanka…',
                                    hintStyle: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) =>
                                      setState(() => _searchActive = false),
                                )
                              : Text(
                                  _searchCtrl.text.isEmpty
                                      ? 'Search location…'
                                      : _searchCtrl.text,
                                  style: TextStyle(
                                    color: _searchCtrl.text.isEmpty
                                        ? Colors.white54
                                        : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                        if (_searchActive)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _searchActive = false);
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.black45,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // LIVE badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF34D399).withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Saved safe zones list
              Positioned(
                bottom: _showRoute ? 230 : 12,
                left: 12,
                right: 62,
                child: _myZones.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              color: Colors.white54,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No safe zones yet · tap Safe Zone to add',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              'SAFE ZONES (${_myZones.length})',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          ..._myZones.map(
                            (z) => Container(
                              margin: const EdgeInsets.only(top: 1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.72),
                                border: Border(
                                  left: BorderSide(
                                    color: Color(z.colorHex),
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    z.icon,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 7),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        z.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${z.start} → ${z.end}',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: z.inZone
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFFF87171),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              // Safe Zone button
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _showRoute = !_showRoute;
                    _searchActive = false;
                    _routeSaved = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _showRoute
                          ? color
                          : Colors.black.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _showRoute ? color : Colors.white24,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: _showRoute ? Colors.white : Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Safe Zone',
                          style: TextStyle(
                            color: _showRoute ? Colors.white : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // My location button
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),

              // Safe zone route panel
              if (_showRoute)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      // Drag down faster than 200 px/s → dismiss
                      if (details.primaryVelocity != null &&
                          details.primaryVelocity! > 200) {
                        setState(() => _showRoute = false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      decoration: BoxDecoration(
                        color: widget.T.card,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle — also tappable to dismiss
                          GestureDetector(
                            onTap: () => setState(() => _showRoute = false),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: widget.T.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.shield_rounded,
                                color: widget.T.cyan,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Safe Zone for ${c.name}",
                                style: TextStyle(
                                  color: widget.T.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _RouteField(
                            ctrl: _startCtrl,
                            label: 'Starting Point',
                            hint: 'e.g. Home, Colombo',
                            dotColor: widget.T.green,
                            T: widget.T,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: List.generate(
                                3,
                                (_) => Container(
                                  width: 2,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  color: widget.T.border,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _RouteField(
                            ctrl: _endCtrl,
                            label: 'Ending Point',
                            hint: 'e.g. School, Kandy',
                            dotColor: widget.T.red,
                            T: widget.T,
                          ),
                          const SizedBox(height: 14),
                          if (_routeSaved)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.T.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.T.green.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: widget.T.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Safe zone saved!',
                                    style: TextStyle(
                                      color: widget.T.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: PrimaryBtn(
                                    label: '🛡️  Save Safe Zone',
                                    T: widget.T,
                                    onTap: () {
                                      if (_startCtrl.text.isNotEmpty &&
                                          _endCtrl.text.isNotEmpty) {
                                        final zone = ZoneModel(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch,
                                          childId: c.id,
                                          name: _startCtrl.text
                                              .split(',')
                                              .first
                                              .trim(),
                                          icon: '📍',
                                          start: _startCtrl.text,
                                          end: _endCtrl.text,
                                          radius: 300,
                                          colorHex: c.colorHex,
                                          active: true,
                                          inZone: true,
                                        );
                                        widget.onAddZone(
                                          zone,
                                        ); // save to main.dart - shared with SafeZone screen
                                        _startCtrl.clear();
                                        _endCtrl.clear();
                                        setState(() => _routeSaved = true);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _showRoute = false),
                                  child: Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: widget.T.card2,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.T.border,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: widget.T.sub,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Route input field
class _RouteField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final Color dotColor;
  final AppTheme T;
  const _RouteField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.dotColor,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: T.card2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: T.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: T.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                TextField(
                  controller: ctrl,
                  style: TextStyle(color: T.text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: T.muted, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//  SRI LANKA MAP PAINTER
class _SriLankaMap extends CustomPainter {
  final Color childColor;
  final String childName;
  final String childAvatar;
  final List<ZoneModel> zones;
  const _SriLankaMap({
    required this.childColor,
    required this.childName,
    required this.childAvatar,
    required this.zones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Ocean background ─────────────────────────────
    final rect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0A1F35), Color(0xFF0D2B4A), Color(0xFF071525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
    );

    // Subtle wave texture
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;
    for (double y = 0; y < h; y += 22) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x < w; x += 40) {
        path.quadraticBezierTo(x + 20, y - 5, x + 40, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    final double left = w * 0.18;
    final double right = w * 0.82;
    final double top = h * 0.06;
    final double bottom = h * 0.94;
    final double mw = right - left;
    final double mh = bottom - top;

    Offset geo(double lat, double lng) {
      final x = left + ((lng - 79.6) / (81.9 - 79.6)) * mw;
      final y = bottom - ((lat - 5.9) / (10.0 - 5.9)) * mh;
      return Offset(x, y);
    }

    final island = Path();
    // Clockwise from north tip
    final pts = [
      [9.70, 80.00], // Jaffna north tip
      [9.55, 80.40], // Trincomalee direction
      [9.30, 80.70],
      [8.85, 81.20], // Trincomalee
      [8.40, 81.60],
      [8.00, 81.80], // East coast
      [7.40, 81.65],
      [6.85, 81.85],
      [6.30, 81.70],
      [5.92, 80.55], // Dondra head (south tip)
      [6.00, 80.20],
      [6.15, 79.85], // Galle
      [6.55, 79.70], // Colombo area
      [7.10, 79.85],
      [7.85, 79.90], // North-west
      [8.45, 79.90],
      [8.90, 79.85],
      [9.35, 79.90], // North approach
      [9.70, 80.00], // back to start
    ];
    island.moveTo(geo(pts[0][0], pts[0][1]).dx, geo(pts[0][0], pts[0][1]).dy);
    for (int i = 1; i < pts.length; i++) {
      island.lineTo(geo(pts[i][0], pts[i][1]).dx, geo(pts[i][0], pts[i][1]).dy);
    }
    island.close();

    // Island fill — lush green gradient
    canvas.drawPath(
      island,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF1D5C2A),
            const Color(0xFF2E7A3C),
            const Color(0xFF176028),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(left, top, mw, mh)),
    );

    // Island coastline
    canvas.drawPath(
      island,
      Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Central highlands area
    canvas.drawCircle(
      geo(7.3, 80.6),
      mw * 0.12,
      Paint()..color = const Color(0xFF1A4F22).withOpacity(0.6),
    );

    // ── Major roads / highways
    void drawRoad(List<List<double>> waypoints, double width, Color color) {
      if (waypoints.isEmpty) return;
      final path = Path()
        ..moveTo(
          geo(waypoints[0][0], waypoints[0][1]).dx,
          geo(waypoints[0][0], waypoints[0][1]).dy,
        );
      for (int i = 1; i < waypoints.length; i++) {
        path.lineTo(
          geo(waypoints[i][0], waypoints[i][1]).dx,
          geo(waypoints[i][0], waypoints[i][1]).dy,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final highway = const Color(0xFF3A5C40);
    final road = const Color(0xFF2E4A35);
    // A1: Colombo → Kandy
    drawRoad(
      [
        [6.93, 79.85],
        [7.00, 80.10],
        [7.10, 80.25],
        [7.29, 80.64],
      ],
      2.5,
      highway,
    );
    // A2: Colombo → Galle
    drawRoad(
      [
        [6.93, 79.85],
        [6.70, 79.88],
        [6.40, 79.95],
        [6.05, 80.22],
        [5.95, 80.55],
      ],
      2.5,
      highway,
    );
    // A3: Colombo → Negombo
    drawRoad(
      [
        [6.93, 79.85],
        [7.15, 79.87],
        [7.35, 79.86],
        [7.60, 79.87],
      ],
      2.0,
      road,
    );
    // A6: Kandy → Trincomalee
    drawRoad(
      [
        [7.29, 80.64],
        [7.60, 80.90],
        [8.00, 81.10],
        [8.60, 81.20],
      ],
      2.0,
      road,
    );
    // A9: Colombo → Jaffna
    drawRoad(
      [
        [6.93, 79.85],
        [7.85, 79.90],
        [8.45, 79.92],
        [9.00, 80.00],
        [9.70, 80.00],
      ],
      2.0,
      road,
    );

    // ── Cities ────────────────────────────────────────
    void city(
      double lat,
      double lng,
      String name,
      double radius,
      Color col, {
      bool capital = false,
    }) {
      final pt = geo(lat, lng);
      // Glow
      canvas.drawCircle(pt, radius + 5, Paint()..color = col.withOpacity(0.12));
      // Dot
      canvas.drawCircle(pt, radius, Paint()..color = col);
      canvas.drawCircle(
        pt,
        radius,
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      // Inner white dot for capital
      if (capital)
        canvas.drawCircle(
          pt,
          radius * 0.45,
          Paint()..color = Colors.white.withOpacity(0.9),
        );
      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.88),
            fontSize: capital ? 11 : 9,
            fontWeight: capital ? FontWeight.w700 : FontWeight.w500,
            shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pt.dx + radius + 4, pt.dy - tp.height / 2));
    }

    city(6.93, 79.85, 'Colombo', 5.5, const Color(0xFFFFA726), capital: true);
    city(7.29, 80.64, 'Kandy', 4.5, const Color(0xFF66BB6A));
    city(6.05, 80.22, 'Galle', 4.0, const Color(0xFF42A5F5));
    city(8.60, 81.20, 'Trincomalee', 4.0, const Color(0xFF26C6DA));
    city(9.70, 80.00, 'Jaffna', 4.0, const Color(0xFFAB47BC));
    city(7.29, 81.67, 'Batticaloa', 3.5, const Color(0xFF26A69A));
    city(6.85, 81.05, 'Badulla', 3.5, const Color(0xFFEC407A));
    city(7.48, 80.36, 'Kurunegala', 3.5, const Color(0xFFFF7043));
    city(8.00, 80.40, 'Anuradhapura', 4.0, const Color(0xFFFFCA28));
    city(7.93, 81.55, 'Polonnaruwa', 3.5, const Color(0xFF9CCC65));

    // ── Draw saved safe zones on map

    final zonePositions = <String, Offset>{
      'home': geo(6.93, 79.85),
      'colombo': geo(6.93, 79.85),
      'kandy': geo(7.29, 80.64),
      'galle': geo(6.05, 80.22),
      'school': geo(7.29, 80.64),
      'trincomalee': geo(8.60, 81.20),
      'jaffna': geo(9.70, 80.00),
    };
    for (final z in zones) {
      final name = z.name.toLowerCase();
      final start = z.start.toLowerCase();

      Offset? pos;
      for (final key in zonePositions.keys) {
        if (start.contains(key) || name.contains(key)) {
          pos = zonePositions[key];
          break;
        }
      }
      pos ??= geo(7.0 + (z.id % 10) * 0.15, 80.2 + (z.id % 8) * 0.1);
      final zColor = Color(z.colorHex);
      // Zone circle
      canvas.drawCircle(pos, 28, Paint()..color = zColor.withOpacity(0.18));
      canvas.drawCircle(
        pos,
        28,
        Paint()
          ..color = zColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // Zone label
      final tp = TextPainter(
        text: TextSpan(text: z.icon, style: const TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
      // Status dot
      canvas.drawCircle(
        Offset(pos.dx + 20, pos.dy - 20),
        5,
        Paint()
          ..color = z.inZone
              ? const Color(0xFF34D399)
              : const Color(0xFFF87171),
      );
    }

    final childPos = geo(7.29, 80.64);
    // Geofence circle
    canvas.drawCircle(
      childPos,
      30,
      Paint()..color = childColor.withOpacity(0.12),
    );
    canvas.drawCircle(
      childPos,
      30,
      Paint()
        ..color = childColor.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Pin shadow
    canvas.drawCircle(
      childPos.translate(2, 2),
      15,
      Paint()..color = Colors.black.withOpacity(0.25),
    );
    // Pin body
    canvas.drawCircle(childPos, 15, Paint()..color = childColor);
    canvas.drawCircle(
      childPos,
      15,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // White centre
    canvas.drawCircle(
      childPos,
      6,
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Route line: Colombo → Kandy
    final routePath = Path()
      ..moveTo(geo(6.93, 79.85).dx, geo(6.93, 79.85).dy)
      ..lineTo(geo(7.10, 80.25).dx, geo(7.10, 80.25).dy)
      ..lineTo(geo(7.29, 80.64).dx, geo(7.29, 80.64).dy);
    canvas.drawPath(
      routePath,
      Paint()
        ..color = childColor.withOpacity(0.8)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Start marker at Colombo
    final colombo = geo(6.93, 79.85);
    canvas.drawCircle(colombo, 8, Paint()..color = const Color(0xFF34D399));
    canvas.drawCircle(
      colombo,
      8,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ── Map title
    final title = TextPainter(
      text: const TextSpan(
        text: 'SRI LANKA',
        style: TextStyle(
          color: Color(0x3AFFFFFF),
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    title.paint(canvas, Offset((w - title.width) / 2, h * 0.88));
  }

  @override
  bool shouldRepaint(_SriLankaMap old) {
    if (old.childColor != childColor) return true;
    if (old.childName != childName) return true;
    if (old.zones.length != zones.length) return true;
    // Force repaint if any zone content changed
    for (int i = 0; i < zones.length; i++) {
      if (old.zones[i].id != zones[i].id) return true;
      if (old.zones[i].inZone != zones[i].inZone) return true;
      if (old.zones[i].colorHex != zones[i].colorHex) return true;
    }
    return false;
  }
}
