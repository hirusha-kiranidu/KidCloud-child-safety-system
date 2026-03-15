import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// Signup Screen
class SignupScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const SignupScreen({super.key, required this.go, required this.T});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  bool _agreed = false;

  Color get _strengthColor {
    final l = _pass.text.length;
    if (l >= 8) return widget.T.green;
    if (l >= 4) return widget.T.yellow;
    return widget.T.red;
  }

  String get _strengthLabel {
    final l = _pass.text.length;
    if (l >= 8) return "Strong";
    if (l >= 4) return "Medium";
    return "Weak";
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          KCTopBar(
            title: "Create Account",
            sub: "Sign up to continue",
            onBack: () => widget.go("welcome"),
            T: T,
          ),

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

          KCInput(
            label: "Password",
            placeholder: "Enter password",
            icon: "🔒",
            controller: _pass,
            obscure: true,
            T: T,
          ),

          ValueListenableBuilder(
            valueListenable: _pass,
            builder: (_, __, ___) => Text(
              "Password Strength: $_strengthLabel",
              style: TextStyle(color: _strengthColor),
            ),
          ),

          KCInput(
            label: "Confirm Password",
            placeholder: "Re-enter password",
            icon: "🔐",
            controller: _confirm,
            obscure: true,
            T: T,
          ),

          Row(
            children: [
              Checkbox(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v!),
              ),
              const Text("I agree to Terms and Privacy Policy"),
            ],
          ),

          const SizedBox(height: 20),

          PrimaryBtn(
            label: "Create Account",
            onTap: () => widget.go("otp"),
            T: T,
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => widget.go("login"),
            child: const Text("Already have an account? Sign In"),
          ),
        ],
      ),
    );
  }
}

// Login Screen
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          KCTopBar(
            title: "Welcome Back",
            sub: "Sign in to continue",
            onBack: () => widget.go("welcome"),
            T: T,
          ),

          KCInput(
            label: "Email",
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
            child: Text("Forgot Password?", style: TextStyle(color: T.cyan)),
          ),

          const SizedBox(height: 20),

          PrimaryBtn(label: "Sign In", onTap: () => widget.go("otp"), T: T),

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
                child: _SocialBtn(icon: "🔵", label: "Google", T: T),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SocialBtn(icon: "🍎", label: "Apple", T: T),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SocialBtn(icon: "📘", label: "Facebook", T: T),
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
    );
  }
}

// Social Button
class _SocialBtn extends StatelessWidget {
  final String icon;
  final String label;
  final AppTheme T;

  const _SocialBtn({required this.icon, required this.label, required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: T.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Text(label),
        ],
      ),
    );
  }
}
