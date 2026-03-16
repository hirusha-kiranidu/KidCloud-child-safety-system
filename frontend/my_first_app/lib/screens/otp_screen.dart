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

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // OTP controllers
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  // Timer variables
  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  bool _canResend = false;
  late Timer _timer;

  // Verification flags
  bool _isSuccess = false;
  bool _isError = false;
  bool _isVerifying = false;
  String _errorMsg = '';

  // ── Shake animation (Commit 9)
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    _startTimer();

    // Initialize shake animation
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnim = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  // Timer start
  void _startTimer() {
    _secondsLeft = _totalSeconds;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // Timer display
  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Timer progress
  double get _timerProgress => _secondsLeft / _totalSeconds;

  // OTP code helper
  String get _otpCode => _controllers.map((c) => c.text).join();

  // Resend OTP
  void _resendOtp() {
    if (!_canResend) return;

    for (final c in _controllers) {
      c.clear();
    }

    _focusNodes[0].requestFocus();

    setState(() {
      _isError = false;
      _errorMsg = '';
    });

    _timer.cancel();
    _startTimer();
  }

  // Verify OTP
  void _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _isError = true;
        _errorMsg = "Please enter all 6 digits";
      });

      _shakeCtrl.forward(from: 0); // trigger shake
      return;
    }

    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) widget.go('dashboard');
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
              "OTP Verification",
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
                fontSize: 28,
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
              onPressed: _isVerifying ? null : _verifyOtp,
              child: _isVerifying
                  ? const CircularProgressIndicator()
                  : const Text("Verify OTP"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _canResend ? _resendOtp : null,
              child: Text(
                _canResend ? "Resend OTP" : "Resend in $_timerDisplay",
              ),
            ),

            const SizedBox(height: 20),

            if (_isError)
              Text(
                _errorMsg,
                style: TextStyle(
                  color: widget.T.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (_isSuccess)
              Text(
                "OTP Verified Successfully!",
                style: TextStyle(
                  color: widget.T.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
