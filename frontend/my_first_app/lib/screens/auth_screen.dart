import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ── Signup Screen ─────────────────────────────────────────
class SignupScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const SignupScreen({super.key, required this.go, required this.T});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 1;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _agreed = false;
  bool _showPass = false;

  Color get _strengthColor {
    final l = _pass.text.length;
    if (l >= 8) return widget.T.green;
    if (l >= 4) return widget.T.yellow;
    return widget.T.red;
  }

  String get _strengthLabel {
    final l = _pass.text.length;
    if (l >= 8) return "Strong ✓";
    if (l >= 4) return "Medium";
    return "Weak";
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final font = GoogleFonts.nunito().fontFamily;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [T.bgTop, T.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KCTopBar(
              title: "Create Account",
              sub: "Step $_step of 2",
              onBack: () =>
                  _step == 1 ? widget.go("welcome") : setState(() => _step = 1),
              T: T,
            ),
            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: T.border),
                boxShadow: [
                  BoxShadow(
                    color: T.cyan.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_step == 1) ...[
                    KCInput(
                      label: "Full Name",
                      placeholder: "Alex Johnson",
                      icon: "👤",
                      controller: _name,
                      T: T,
                    ),
                    KCInput(
                      label: "Email",
                      placeholder: "you@email.com",
                      icon: "✉️",
                      controller: _email,
                      T: T,
                    ),
                    KCInput(
                      label: "Phone",
                      placeholder: "+94 7X XXX XXXX",
                      icon: "📱",
                      controller: _phone,
                      T: T,
                    ),
                    const SizedBox(height: 14),
                    PrimaryBtn(
                      label: "Continue →",
                      onTap: () => setState(() => _step = 2),
                      T: T,
                      gradient: LinearGradient(colors: [T.cyan, T.blue]),
                    ),
                  ] else ...[
                    KCInput(
                      label: "Password",
                      placeholder: "Enter password",
                      icon: "🔒",
                      controller: _pass,
                      obscure: !_showPass,
                      T: T,
                    ),
                    KCInput(
                      label: "Confirm Password",
                      placeholder: "Re-enter password",
                      icon: "🔐",
                      controller: _confirm,
                      obscure: !_showPass,
                      T: T,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: T.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Password Strength",
                            style: TextStyle(
                              color: T.sub,
                              fontSize: 13,
                              fontFamily: font,
                            ),
                          ),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              color: _strengthColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v!),
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to Terms of Service & Privacy Policy",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryBtn(
                      label: "Create Account 🎉",
                      onTap: () => widget.go("otp"),
                      T: T,
                      gradient: LinearGradient(colors: [T.cyan, T.blue]),
                    ),
                  ],
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => widget.go("login"),
                    child: const Center(
                      child: Text("Already have an account? Sign In"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Login Screen ─────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const LoginScreen({super.key, required this.go, required this.T});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final font = GoogleFonts.nunito().fontFamily;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [T.bgTop, T.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            KCTopBar(
              title: "Welcome Back",
              sub: "Sign in to continue",
              onBack: () => widget.go("welcome"),
              T: T,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: T.border),
                boxShadow: [
                  BoxShadow(
                    color: T.cyan.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  KCInput(
                    label: "Email or Phone",
                    placeholder: "you@email.com",
                    icon: "✉️",
                    T: T,
                  ),
                  KCInput(
                    label: "Password",
                    placeholder: "Enter password",
                    icon: "🔒",
                    obscure: _obscurePass,
                    T: T,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: T.cyan),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryBtn(
                    label: "Sign In →",
                    onTap: () => widget.go("otp"),
                    T: T,
                    gradient: LinearGradient(colors: [T.cyan, T.blue]),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialBtn(
                          icon: "🔵",
                          label: "Google",
                          onTap: () => widget.go("otp"),
                          T: T,
                          gradient: LinearGradient(colors: [T.cyan, T.blue]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SocialBtn(
                          icon: "🍎",
                          label: "Apple",
                          onTap: () => widget.go("otp"),
                          T: T,
                          gradient: LinearGradient(colors: [T.cyan, T.blue]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SocialBtn(
                          icon: "📘",
                          label: "Facebook",
                          onTap: () => widget.go("otp"),
                          T: T,
                          gradient: LinearGradient(colors: [T.cyan, T.blue]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => widget.go("signup"),
                    child: const Text("Need an account? Sign up here"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final AppTheme T;
  final Gradient? gradient;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.T,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: T.border),
          borderRadius: BorderRadius.circular(14),
          gradient: gradient,
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: GoogleFonts.nunito().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
