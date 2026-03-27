import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class SOSScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children; // live list
  final AppTheme T;
  const SOSScreen(
      {super.key, required this.go, required this.children, required this.T});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _flash = false, _alertSent = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (mounted) setState(() => _flash = !_flash);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  ChildModel? get _sosChild {
    if (widget.children.isEmpty) return null;
    return widget.children
        .firstWhere((c) => c.online, orElse: () => widget.children.first);
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final child = _sosChild;
    final name = child?.name ?? 'Your Child';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(children: [
        KCTopBar(
            title: '🚨 Emergency SOS',
            onBack: () => widget.go('dashboard'),
            T: T),

        // ── Pulsing alert banner ─────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _flash ? T.red.withOpacity(0.13) : T.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: T.red, width: 2),
          ),
          child: Column(children: [
            const Text('🆘', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text('EMERGENCY SOS ACTIVE',
                style: TextStyle(
                    color: T.red, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('$name · SOS Triggered',
                style: TextStyle(
                    color: T.text, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (child != null)
                Pill(text: 'Battery: ${child.battery}%', color: T.red),
              const SizedBox(width: 8),
              Pill(text: 'GPS: Active', color: T.orange),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        // ── Map ──────────────────────────────────────
        MapPlaceholder(height: 130, T: T),
        const SizedBox(height: 8),
        Text(
          child != null
              ? '📍 ${child.status} · Location being tracked'
              : '📍 Waiting for GPS signal…',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: T.text, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),

        // ── Alert sent confirmation ──────────────────
        if (_alertSent)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
                color: T.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.green, width: 1.5)),
            child: Column(children: [
              const Text('✅', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text('Alert Sent Successfully!',
                  style: TextStyle(
                      color: T.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  'Emergency contacts notified · Location shared · Saved in history',
                  style: TextStyle(color: T.sub, fontSize: 12)),
            ]),
          ),

        // ── Action buttons (Send SOS + Call Child removed) ──
        PrimaryBtn(
          label: _alertSent
              ? '✅ Alert Already Sent'
              : '📲 Send Alert to All Contacts',
          onTap: _alertSent ? () {} : () => setState(() => _alertSent = true),
          T: T,
          danger: !_alertSent,
        ),
        const SizedBox(height: 9),
        PrimaryBtn(
            label: '📍 Navigate to Location',
            onTap: () => widget.go('tracking'),
            T: T),
        const SizedBox(height: 9),
        PrimaryBtn(
            label: '📲 Share Live Location with Contacts',
            onTap: () {},
            T: T,
            ghost: true),
        const SizedBox(height: 9),
        PrimaryBtn(
            label: '🚓 Contact Emergency Services (119)',
            onTap: () {},
            T: T,
            ghost: true),
      ]),
    );
  }
}
