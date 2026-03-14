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
