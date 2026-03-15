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
    if (l >= 8) return 'Strong ✓';
    if (l >= 4) return 'Medium';
    return 'Weak';
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final font = GoogleFonts.nunito().fontFamily;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [T.bgTop, T.bgBottom],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KCTopBar(
              title: 'Create Account',
              sub: 'Step $_step of 2',
              onBack: () =>
                  _step == 1 ? widget.go('welcome') : setState(() => _step = 1),
              T: T,
            ),
            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: T.border,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                widthFactor: _step / 2,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [T.cyan, T.blue]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            if (_step == 1) ...[
              _SectionLabel('Personal Info', T, font),
              KCInput(
                label: 'Full Name',
                placeholder: 'Alex Johnson',
                icon: '👤',
                controller: _name,
                T: T,
              ),
              KCInput(
                label: 'Email Address',
                placeholder: 'you@email.com',
                icon: '✉️',
                controller: _email,
                T: T,
                keyboardType: TextInputType.emailAddress,
              ),
              KCInput(
                label: 'Phone Number',
                placeholder: '+60 1X XXX XXXX',
                icon: '📱',
                controller: _phone,
                T: T,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 6),
              PrimaryBtn(
                label: 'Continue  →',
                onTap: () => setState(() => _step = 2),
                T: T,
              ),
            ] else ...[
              _SectionLabel('Set Password', T, font),
              KCInput(
                label: 'Password',
                placeholder: 'Min 8 characters',
                icon: '🔒',
                controller: _pass,
                T: T,
                obscure: !_showPass,
              ),
              KCInput(
                label: 'Confirm Password',
                placeholder: 'Re-enter password',
                icon: '🔐',
                controller: _confirm,
                T: T,
                obscure: !_showPass,
              ),
              ValueListenableBuilder(
                valueListenable: _pass,
                builder: (_, __, ___) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: T.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password strength',
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
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: font,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: T.border,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: (_pass.text.length / 10).clamp(0, 1),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _strengthColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _agreed
                            ? T.cyan.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: T.cyan, width: 2),
                      ),
                      child: _agreed
                          ? Icon(Icons.check, size: 13, color: T.cyan)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: T.sub,
                          fontSize: 13,
                          height: 1.6,
                          fontFamily: font,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: T.cyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: T.cyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryBtn(
                label: 'Create Account  🎉',
                onTap: () => widget.go('otp'),
                T: T,
              ),
            ],

            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () => widget.go('login'),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: T.sub,
                      fontSize: 14,
                      fontFamily: font,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account?  '),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: T.cyan,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Login Screen ──────────────────────────────────────────
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [T.bgTop, T.bgBottom],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          children: [
            KCTopBar(
              title: 'Welcome Back 👋',
              sub: 'Sign in to KidCloud',
              onBack: () => widget.go('welcome'),
              T: T,
            ),
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [T.cyan, T.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: T.cyan.withOpacity(0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('☁️', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'KidCloud',
              style: TextStyle(
                color: T.text,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                fontFamily: font,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fund your child\'s safety everywhere',
              style: TextStyle(
                color: T.sub,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: font,
              ),
            ),
            const SizedBox(height: 28),

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
                    label: 'Email or Phone',
                    placeholder: 'you@email.com',
                    icon: '✉️',
                    T: T,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  KCInput(
                    label: 'Password',
                    placeholder: 'Your password',
                    icon: '🔒',
                    T: T,
                    obscure: _obscurePass,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: T.cyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: font,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryBtn(
              label: 'Sign In  →',
              onTap: () => widget.go('otp'),
              T: T,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: Divider(color: T.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: T.sub,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: font,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: T.border)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _SocialBtn(
                    icon: '🔵',
                    label: 'Google',
                    onTap: () => widget.go('otp'),
                    T: T,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialBtn(
                    icon: '🍎',
                    label: 'Apple',
                    onTap: () => widget.go('otp'),
                    T: T,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SocialBtn(
                    icon: '🔷',
                    label: 'Facebook',
                    onTap: () => widget.go('otp'),
                    T: T,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () => widget.go('signup'),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: T.sub,
                    fontSize: 14,
                    fontFamily: font,
                  ),
                  children: [
                    const TextSpan(text: 'Need an account?  '),
                    TextSpan(
                      text: 'Sign up here',
                      style: TextStyle(
                        color: T.cyan,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
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
  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: T.border, width: 1.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: T.sub,
                fontSize: 11,
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

// ── Section Label ─────────────────────────────────────────
Widget _SectionLabel(String text, AppTheme T, String? font) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        color: T.text,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        fontFamily: font,
      ),
    ),
  );
}
