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
  // OTP Controllers
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // Timer variables
  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  bool _canResend = false;
  late Timer _timer;

  // Error flag
  bool _isError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Start countdown timer
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

  // Timer display helper
  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Timer progress helper
  double get _timerProgress => _secondsLeft / _totalSeconds;

  // ═══════════════════════════════
  // RESEND OTP FUNCTION
  // ═══════════════════════════════
  void _resendOtp() {
    if (!_canResend) return;

    // Clear OTP boxes
    for (final c in _controllers) {
      c.clear();
    }

    // Focus first box
    _focusNodes[0].requestFocus();

    // Reset errors
    setState(() {
      _isError = false;
      _errorMsg = '';
    });

    // Restart timer
    _timer.cancel();
    _startTimer();

    // TODO: call backend resend API
  }

  @override
  Widget build(BuildContext context) {
    final urgentColor = (_secondsLeft < 60 && !_canResend)
        ? widget.T.red
        : widget.T.cyan;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "OTP Timer",
              style: TextStyle(
                fontSize: 20,
                color: widget.T.text,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              _timerDisplay,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: urgentColor,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: _timerProgress,
                strokeWidth: 6,
                backgroundColor: widget.T.border,
                valueColor: AlwaysStoppedAnimation(urgentColor),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend ? "Resend OTP" : "Resend in $_timerDisplay",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
