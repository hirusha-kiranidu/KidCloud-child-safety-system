import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SignupScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const SignupScreen({super.key, required this.go, required this.T});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _step = 1;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _agreed = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Color get _strengthColor {
    final l = _pass.text.length;
    if (l >= 8) return widget.T.green;
    if (l >= 4) return widget.T.yellow;
    return widget.T.red;
  }

  String get _strengthLabel {
    final l = _pass.text.length;
    if (l >= 8) return 'Strong';
    if (l >= 4) return 'Medium';
    return 'Weak';
  }

  void _goToStep2() {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your first and last name');
      return;
    }
    if (_email.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() {
      _error = null;
      _step = 2;
    });
  }

  void _submitSignup() {
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (!_agreed) {
      setState(() => _error = 'Please accept the Terms of Service');
      return;
    }
    if (_pass.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() => _error = null);

    widget.go('otp');
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                    children: [
                      TextSpan(
                        text: 'Kid',
                        style: TextStyle(color: T.text),
                      ),
                      TextSpan(
                        text: 'Cloud',
                        style: TextStyle(color: T.cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          KCTopBar(
            title: 'Create Account',
            sub: 'Step $_step of 2',
            onBack: () =>
                _step == 1 ? widget.go('welcome') : setState(() => _step = 1),
            T: T,
          ),

          Container(
            height: 5,
            decoration: BoxDecoration(
              color: T.card2,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: _step / 2,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [T.cyan, T.orange]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_error != null) ...[
            _ErrorBanner(message: _error!, T: T),
            const SizedBox(height: 12),
          ],

          if (_step == 1) ...[
            Row(
              children: [
                Expanded(
                  child: KCInput(
                    label: 'First Name *',
                    placeholder: 'e.g. Sarah',
                    icon: '👤',
                    controller: _firstName,
                    T: T,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KCInput(
                    label: 'Last Name *',
                    placeholder: 'e.g. Johnson',
                    icon: '👤',
                    controller: _lastName,
                    T: T,
                  ),
                ),
              ],
            ),
            KCInput(
              label: 'Email Address *',
              placeholder: 'you@email.com',
              icon: '✉️',
              controller: _email,
              T: T,
              keyboardType: TextInputType.emailAddress,
            ),
            KCInput(
              label: 'Phone Number *',
              placeholder: '+94 7X XXX XXXX',
              icon: '📱',
              controller: _phone,
              T: T,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            PrimaryBtn(label: 'Continue →', onTap: _goToStep2, T: T),
          ] else ...[
            KCInput(
              label: 'Password',
              placeholder: 'Min 8 characters',
              icon: '🔒',
              controller: _pass,
              T: T,
              obscure: true,
            ),
            KCInput(
              label: 'Confirm Password',
              placeholder: 'Re-enter password',
              icon: '🔐',
              controller: _confirm,
              T: T,
              obscure: true,
            ),

            ValueListenableBuilder(
              valueListenable: _pass,
              builder: (_, __, ___) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: T.card2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: T.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Password strength',
                          style: TextStyle(color: T.sub, fontSize: 11),
                        ),
                        Text(
                          _strengthLabel,
                          style: TextStyle(
                            color: _strengthColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: T.card,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: (_pass.text.length / 10)
                            .clamp(0, 1)
                            .toDouble(),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _strengthColor,
                            borderRadius: BorderRadius.circular(4),
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
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _agreed
                          ? T.cyan.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: T.cyan, width: 1.5),
                    ),
                    child: _agreed
                        ? Icon(Icons.check, size: 12, color: T.cyan)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: T.sub,
                        fontSize: 11,
                        height: 1.65,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: T.cyan),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: T.cyan),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            PrimaryBtn(label: 'Create Account →', onTap: _submitSignup, T: T),
          ],

          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => widget.go('login'),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: T.sub, fontSize: 12),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign In',
                      style: TextStyle(
                        color: T.cyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const LoginScreen({super.key, required this.go, required this.T});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Please enter your email and password');
      return;
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Image.asset(
            'assets/images/logo.png',
            width: 110,
            height: 110,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome Back',
            style: TextStyle(
              color: T.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Sign in to your account',
            style: TextStyle(color: T.sub, fontSize: 13),
          ),
          const SizedBox(height: 28),

          if (_error != null) ...[
            _ErrorBanner(message: _error!, T: T),
            const SizedBox(height: 12),
          ],

          KCInput(
            label: 'Email Address',
            placeholder: 'you@email.com',
            icon: '✉️',
            controller: _email,
            T: T,
            keyboardType: TextInputType.emailAddress,
          ),
          KCInput(
            label: 'Password',
            placeholder: 'Your password',
            icon: '🔒',
            controller: _pass,
            T: T,
            obscure: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: T.cyan, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryBtn(label: 'Sign In →', onTap: _submitLogin, T: T),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: T.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('OR', style: TextStyle(color: T.sub, fontSize: 11)),
              ),
              Expanded(child: Divider(color: T.border)),
            ],
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => widget.go('dashboard'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDADADA), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                    height: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Color(0xFF3C4043),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => widget.go('signup'),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: T.sub, fontSize: 12),
                children: [
                  const TextSpan(text: 'No account? '),
                  TextSpan(
                    text: 'Create one free',
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
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final AppTheme T;
  const _ErrorBanner({required this.message, required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: T.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: T.red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: T.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
