import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  late Timer _timer;
  bool _canResend = false;

  bool _isVerifying = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMsg = '';

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = _totalSeconds;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft == 0) {
        t.cancel();
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

  void _resendOtp() {
    if (!_canResend) return;
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    setState(() {
      _isError = false;
      _errorMsg = '';
    });
    _timer.cancel();
    _startTimer();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _isError = true;
        _errorMsg = 'Please enter all 6 digits';
      });
      _shakeCtrl.forward(from: 0);
      return;
    }
    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    _timer.cancel();
    setState(() {
      _isVerifying = false;
      _isSuccess = true;
    });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) widget.go('dashboard');
  }

  Widget _buildOtpBox(int index) {
    final T = widget.T;
    final isFilled = _controllers[index].text.isNotEmpty;

    Color borderColor;
    Color textColor;
    if (_isError) {
      borderColor = T.red;
      textColor = T.red;
    } else if (_isSuccess) {
      borderColor = T.green;
      textColor = T.green;
    } else if (isFilled) {
      borderColor = T.cyan;
      textColor = T.cyan;
    } else {
      borderColor = T.border;
      textColor = T.text;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: isFilled ? T.cyan.withOpacity(0.08) : T.card2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isFilled
            ? [BoxShadow(color: T.cyan.withOpacity(0.2), blurRadius: 12)]
            : null,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() => _isError = false);
          if (val.isNotEmpty) {
            if (index < 5)
              _focusNodes[index + 1].requestFocus();
            else {
              _focusNodes[index].unfocus();
              _verifyOtp();
            }
          } else {
            if (index > 0) _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final urgentColor = (_secondsLeft < 60 && !_canResend) ? T.red : T.cyan;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [T.bgTop, T.bgBottom],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top back + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.go('signup'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: T.card2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: T.border),
                      ),
                      child: Icon(Icons.chevron_left, color: T.text, size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Phone 📱',
                        style: TextStyle(
                          color: T.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Enter the 6-digit code we sent you',
                        style: TextStyle(color: T.sub, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Shield icon (commit 13) ─────────────
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [T.cyan, T.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: T.cyan.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔐', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ── OTP title and description (to be next commits)
              Center(
                child: Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: T.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: T.sub, fontSize: 14, height: 1.6),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit code to\n'),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: TextStyle(
                          color: T.cyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
