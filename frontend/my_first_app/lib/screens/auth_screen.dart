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
<<<<<<< HEAD
=======
  final _phone = TextEditingController();
>>>>>>> 2e902e3 (implement password and confirm password inputs)

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
<<<<<<< HEAD
=======

          KCInput(
            label: "Phone",
            placeholder: "+94 7X XXX XXXX",
            icon: "📱",
            controller: _phone,
            T: T,
          ),

          PrimaryBtn(label: "Continue →", onTap: () {}, T: T),
>>>>>>> 2e902e3 (implement password and confirm password inputs)
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
    return Container();
  }
}
