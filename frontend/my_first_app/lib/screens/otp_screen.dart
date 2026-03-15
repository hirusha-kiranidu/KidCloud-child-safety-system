import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.go,
    required this.T,
    this.phoneNumber = '+60 1X XXX XXXX',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ── Controllers and FocusNodes for 6-digit OTP
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'OTP Screen with Controllers & FocusNodes',
          style: TextStyle(
            fontSize: 18,
            color: widget.T.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
