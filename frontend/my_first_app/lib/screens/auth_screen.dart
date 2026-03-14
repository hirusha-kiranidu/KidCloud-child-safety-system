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
                onChanged: (v) {
                  setState(() {
                    _agreed = v!;
                  });
                },
              ),
              const Text("I agree to Terms and Privacy Policy"),
            ],
          ),

          const SizedBox(height: 20),

          PrimaryBtn(label: "Create Account", onTap: () {}, T: T),

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

class LoginScreen extends StatelessWidget {
  final Function(String) go;
  final AppTheme T;

  const LoginScreen({super.key, required this.go, required this.T});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          KCTopBar(
            title: "Welcome Back",
            sub: "Sign in to continue",
            onBack: () => go("welcome"),
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
            obscure: true,
            T: T,
          ),

          const SizedBox(height: 20),

          PrimaryBtn(label: "Sign In", onTap: () => go("dashboard"), T: T),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => go("signup"),
            child: const Text("Create new account"),
          ),
        ],
      ),
    );
  }
}
