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
    this.phoneNumber = '+94 7X XXX XXXX',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  bool _canResend = false;
  late Timer _timer;

  bool _isSuccess = false;
  bool _isError = false;
  bool _isVerifying = false;
  String _errorMsg = '';

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    _startTimer();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnim = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

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

  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _timerProgress => _secondsLeft / _totalSeconds;

  String get _otpCode => _controllers.map((c) => c.text).join();

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

  void _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _isError = true;
        _errorMsg = "Please enter all 6 digits";
      });

      _shakeCtrl.forward(from: 0);
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
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }

    for (final f in _focusNodes) {
      f.dispose();
    }

    _timer.cancel();
    _shakeCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgentColor = (_secondsLeft < 60 && !_canResend)
        ? widget.T.red
        : widget.T.cyan;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.T.mint, widget.T.cyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Back Button ───
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: widget.T.text,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 10),

                // ─── Title ───
                Text(
                  "Verify Phone",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.T.text,
                  ),
                ),

                const SizedBox(height: 10),

                // ─── Description ───
                Text(
                  "Enter the 6-digit code sent to ${widget.phoneNumber}",
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.T.text.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Column(
                    children: [
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
                          _canResend
                              ? "Resend OTP"
                              : "Resend in $_timerDisplay",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
