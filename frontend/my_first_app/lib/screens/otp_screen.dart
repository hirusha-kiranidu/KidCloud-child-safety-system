import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const Color kBg = Color(0xFF07090F);
const Color kCard2 = Color(0xFF182438);
const Color kBorder = Color(0xFF1E2F48);
const Color kText = Color(0xFFEEF4FF);
const Color kSub = Color(0xFF6B85A8);
const Color kMuted = Color(0xFF2E4060);
const Color kCyan = Color(0xFF00E5C8);
const Color kBlue = Color(0xFF2B7EFF);
const Color kGreen = Color(0xFF22D67A);
const Color kRed = Color(0xFFFF3E5E);

class OtpScreen extends StatefulWidget {
  final Function(String) go;
  final String phoneNumber;
  // AppTheme optional — falls back to hardcoded colors if not provided
  const OtpScreen({
    super.key,
    required this.go,
    this.phoneNumber = '+60 1X XXX XXXX',
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // ── 5 minutes = 300 seconds ─────────────────────────────
  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  late Timer _timer;
  bool _canResend = false;

  bool _isVerifying = false;
  bool _isSuccess = false;
  bool _isError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _timer.cancel();
    super.dispose();
  }

  // ── Start / restart 5-min countdown ────────────────────
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

  // ── mm:ss display ───────────────────────────────────────
  String get _timerDisplay {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── 0.0–1.0 progress for ring ──────────────────────────
  double get _timerProgress => _secondsLeft / _totalSeconds;

  // ── Resend ──────────────────────────────────────────────
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
    // TODO: call your resend OTP API here
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  // ── Verify ──────────────────────────────────────────────
  void _verifyOtp() async {
    if (_otpCode.length < 6) {
      setState(() {
        _isError = true;
        _errorMsg = 'Please enter all 6 digits';
      });
      return;
    }
    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    // TODO: Replace with real OTP verification API call
    await Future.delayed(const Duration(seconds: 2));

    if (_otpCode == '123456') {
      _timer.cancel();
      setState(() {
        _isVerifying = false;
        _isSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) widget.go('dashboard');
    } else {
      setState(() {
        _isVerifying = false;
        _isError = true;
        _errorMsg = 'Invalid OTP code. Please try again.';
      });
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  Widget _buildOtpBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    Color borderColor;
    if (_isError)
      borderColor = kRed;
    else if (_isSuccess)
      borderColor = kGreen;
    else if (isFilled)
      borderColor = kCyan;
    else
      borderColor = kBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        color: isFilled ? kCyan.withOpacity(0.08) : kCard2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isFilled
            ? [BoxShadow(color: kCyan.withOpacity(0.15), blurRadius: 8)]
            : null,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          color: _isError
              ? kRed
              : _isSuccess
              ? kGreen
              : kCyan,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() => _isError = false);
          if (val.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
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
    // Turn red when under 60 seconds left
    final urgentColor = (_secondsLeft < 60 && !_canResend) ? kRed : kCyan;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back + title ───────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.go('signup'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kCard2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: kText,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verify Phone 📱',
                        style: TextStyle(
                          color: kText,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Enter the code we sent you',
                        style: TextStyle(color: kSub, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ── Shield icon ────────────────────────
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kCyan, kBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: kCyan.withOpacity(0.35),
                        blurRadius: 36,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🔐', style: TextStyle(fontSize: 42)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ─────────────────────────────
              const Center(
                child: Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: kText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: kSub,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(text: 'We sent a 6-digit code to\n'),
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: kCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════
              //  5-MINUTE COUNTDOWN  (ring + mm:ss)
              // ══════════════════════════════════════
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: _timerProgress,
                            strokeWidth: 5,
                            backgroundColor: kBorder,
                            valueColor: AlwaysStoppedAnimation(urgentColor),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _canResend ? '0:00' : _timerDisplay,
                              style: TextStyle(
                                color: urgentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              _canResend ? 'Expired' : 'left',
                              style: TextStyle(
                                color: _canResend ? kRed : kSub,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _canResend
                          ? 'Code has expired — tap Resend'
                          : (_secondsLeft < 60
                                ? 'Expiring soon!'
                                : 'Code valid for 5 minutes'),
                      style: TextStyle(color: urgentColor, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── OTP boxes ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 16),

              // ── Error / success msg ───────────────
              if (_isError)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: kRed, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _errorMsg,
                        style: const TextStyle(
                          color: kRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isSuccess)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: kGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Verified successfully! Redirecting...',
                        style: TextStyle(
                          color: kGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              // ── Verify button ─────────────────────
              GestureDetector(
                onTap: _isVerifying ? null : _verifyOtp,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _isSuccess
                        ? const LinearGradient(colors: [kGreen, kGreen])
                        : const LinearGradient(
                            colors: [kCyan, kBlue],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kCyan.withOpacity(0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isVerifying
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Text(
                          _isSuccess ? '✅ Verified!' : 'Verify OTP',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Resend section ────────────────────
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the code?",
                      style: TextStyle(color: kSub, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _canResend ? _resendOtp : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _canResend ? kCyan.withOpacity(0.1) : kCard2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _canResend ? kCyan : kBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: _canResend ? kCyan : kSub,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _canResend
                                  ? 'Resend OTP'
                                  : 'Resend in $_timerDisplay',
                              style: TextStyle(
                                color: _canResend ? kCyan : kSub,
                                fontSize: 13,
                                fontWeight: _canResend
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Security note ─────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kCyan.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This code expires in 5 minutes. '
                        'Never share your OTP with anyone.',
                        style: TextStyle(
                          color: kSub,
                          fontSize: 11,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
