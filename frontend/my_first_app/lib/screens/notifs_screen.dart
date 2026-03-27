import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class NotifsScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children; // live list from main.dart
  final AppTheme T;
  const NotifsScreen(
      {super.key, required this.go, required this.children, required this.T});

  @override
  State<NotifsScreen> createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsScreen> {
  String _filter = 'All';

  final List<Map<String, dynamic>> _notifs = [];

  List<String> get _filterOptions {
    final names = widget.children.map((c) => c.name).toList();
    return ['All', 'Urgent', ...names];
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _notifs;
    if (_filter == 'Urgent')
      return _notifs.where((n) => n['urgent'] == true).toList();
    return _notifs.where((n) => n['childName'] == _filter).toList();
  }

  int get _urgentCount => _notifs.where((n) => n['urgent'] == true).length;

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notifications',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w800)),
                Text(
                  _urgentCount > 0
                      ? '$_urgentCount urgent · Today'
                      : 'No urgent alerts · Today',
                  style: TextStyle(color: T.sub, fontSize: 11),
                ),
              ]),
              GestureDetector(
                onTap: () => widget.go('alerthistory'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: T.blue.withOpacity(0.11),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: T.blue)),
                  child: Text('📋 History',
                      style: TextStyle(
                          color: T.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Filter chips — dynamic from live children ──
          if (_filterOptions.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions
                    .map((opt) => GestureDetector(
                          onTap: () => setState(() => _filter = opt),
                          child: Container(
                            margin: const EdgeInsets.only(right: 7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 6),
                            decoration: BoxDecoration(
                              color: _filter == opt ? T.cyan : T.card2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _filter == opt ? T.cyan : T.border),
                            ),
                            child: Text(opt,
                                style: TextStyle(
                                    color:
                                        _filter == opt ? Colors.black : T.sub,
                                    fontSize: 12,
                                    fontWeight: _filter == opt
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 14),

          if (_notifs.isEmpty)
            _EmptyNotifs(children: widget.children, go: widget.go, T: T)
          else if (_filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: T.border)),
              child: Column(children: [
                const Text('🔕', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 10),
                Text('No $_filter notifications',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ]),
            )
          else
            ..._filtered.map((n) {
              final color = Color(n['colorHex'] as int);
              final isUrgent = n['urgent'] as bool;
              return GestureDetector(
                onTap: isUrgent ? () => widget.go('sos') : () {},
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: T.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isUrgent ? color.withOpacity(0.33) : T.border),
                  ),
                  child: Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(n['icon'] as String,
                              style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(n['title'] as String,
                              style: TextStyle(
                                  color: isUrgent ? color : T.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          Text(n['desc'] as String,
                              style: TextStyle(color: T.sub, fontSize: 11)),
                        ])),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(n['time'] as String,
                              style: TextStyle(color: T.muted, fontSize: 10)),
                          if (isUrgent) ...[
                            const SizedBox(height: 4),
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle)),
                          ],
                        ]),
                  ]),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _EmptyNotifs extends StatelessWidget {
  final List<ChildModel> children;
  final Function(String) go;
  final AppTheme T;
  const _EmptyNotifs(
      {required this.children, required this.go, required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: T.border)),
      child: Column(children: [
        const Text('🔔', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 14),
        Text('No Notifications Yet',
            style: TextStyle(
                color: T.text, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          children.isEmpty
              ? 'Add a child and connect their device to start receiving alerts.'
              : 'Alerts for ${children.map((c) => c.name).join(', ')} will appear here once their device is connected.',
          style: TextStyle(color: T.sub, fontSize: 12, height: 1.6),
          textAlign: TextAlign.center,
        ),
        if (children.isEmpty) ...[
          const SizedBox(height: 16),
          PrimaryBtn(label: '➕ Add a Child', onTap: () => go('addchild'), T: T),
        ],
      ]),
    );
  }
}

class AlertHistoryScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const AlertHistoryScreen({super.key, required this.go, required this.T});

  @override
  State<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends State<AlertHistoryScreen> {
  String _filter = 'This Week';

  final List<Map<String, dynamic>> _history = [];

  int get _total =>
      _history.fold(0, (s, d) => s + (d['events'] as List).length);
  int get _resolved => _history.fold(
      0,
      (s, d) =>
          s +
          (d['events'] as List)
              .where((e) => (e as Map)['resolved'] == true)
              .length);

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KCTopBar(
              title: 'Alert History',
              sub: 'Full log of all alerts',
              onBack: () => widget.go('notifs'),
              T: T),
          // Summary cards
          Row(children: [
            _SummaryCard(
                icon: '🚨',
                val: _total,
                label: 'Total Alerts',
                color: T.red,
                T: T),
            const SizedBox(width: 8),
            _SummaryCard(
                icon: '✅',
                val: _resolved,
                label: 'Resolved',
                color: T.green,
                T: T),
            const SizedBox(width: 8),
            _SummaryCard(
                icon: '⏳',
                val: _total - _resolved,
                label: 'Pending',
                color: T.orange,
                T: T),
          ]),
          const SizedBox(height: 14),
          // Date filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Today', 'This Week', 'This Month', 'All Time']
                  .map((f) => GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 7),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _filter == f ? T.cyan : T.card2,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _filter == f ? T.cyan : T.border),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  color: _filter == f ? Colors.black : T.sub,
                                  fontSize: 12,
                                  fontWeight: _filter == f
                                      ? FontWeight.w700
                                      : FontWeight.w400)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Empty state ────────────────────────────
          if (_history.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: T.border)),
              child: Column(children: [
                const Text('📋', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 14),
                Text('No Alert History',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                    'Past alerts will appear here once your children\'s devices are connected.',
                    style: TextStyle(color: T.sub, fontSize: 12, height: 1.6),
                    textAlign: TextAlign.center),
              ]),
            )
          else
            ..._history.map((group) {
              final events = group['events'] as List;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((group['date'] as String).toUpperCase(),
                            style: TextStyle(
                                color: T.sub,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1)),
                        Text('${events.length} alerts',
                            style: TextStyle(color: T.muted, fontSize: 10)),
                      ]),
                  const SizedBox(height: 8),
                  ...events.map((e) {
                    final ev = e as Map;
                    final color = Color(ev['colorHex'] as int);
                    final resolved = ev['resolved'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          color: T.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: resolved
                                  ? T.border
                                  : color.withOpacity(0.27))),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: color.withOpacity(0.11),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                    child: Text(ev['icon'] as String,
                                        style: const TextStyle(fontSize: 18)))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(ev['title'] as String,
                                                style: TextStyle(
                                                    color: resolved
                                                        ? T.text
                                                        : color,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700))),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: resolved
                                                  ? T.green.withOpacity(0.11)
                                                  : color.withOpacity(0.11),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                              resolved
                                                  ? '✓ Resolved'
                                                  : '● Active',
                                              style: TextStyle(
                                                  color: resolved
                                                      ? T.green
                                                      : color,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ]),
                                  const SizedBox(height: 3),
                                  Text(ev['desc'] as String,
                                      style: TextStyle(
                                          color: T.sub, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text('🕐 ${ev['time']}',
                                      style: TextStyle(
                                          color: T.muted, fontSize: 10)),
                                ])),
                          ]),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon, label;
  final int val;
  final Color color;
  final AppTheme T;
  const _SummaryCard(
      {required this.icon,
      required this.val,
      required this.label,
      required this.color,
      required this.T});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
            color: T.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: T.border)),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text('$val',
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: TextStyle(color: T.sub, fontSize: 10)),
        ]),
      ),
    );
  }
}
