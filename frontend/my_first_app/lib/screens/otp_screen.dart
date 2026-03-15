import 'dart:async';
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

  // ── Timer variables
  static const int _totalSeconds = 300; // 5 minutes
  int _secondsLeft = _totalSeconds;
  bool _canResend = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    _startTimer(); // start countdown on init
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer.cancel();
    super.dispose();
  }

  // ── Countdown timer logic
  void _startTimer() {
    _secondsLeft = _totalSeconds;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  // ── Get timer display in mm:ss
  String get _timerDisplay {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OTP Screen Timer Demo',
              style: TextStyle(
                fontSize: 18,
                color: widget.T.text,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _timerDisplay,
              style: TextStyle(
                fontSize: 28,
                color: _secondsLeft < 60 ? widget.T.red : widget.T.cyan,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _canResend ? 'You can resend OTP' : 'Counting down...',
              style: TextStyle(fontSize: 14, color: widget.T.sub),
            ),
          ],
        ),
      ),
    );
  }
}
