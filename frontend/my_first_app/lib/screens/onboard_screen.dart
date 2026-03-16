import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class OnboardScreen extends StatelessWidget {
  final int idx;
  final Function(String) go;
  final AppTheme T;

  const OnboardScreen({
    super.key,
    required this.idx,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text("Onboarding Screen"),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final Function(String) go;
  final AppTheme T;

  const WelcomeScreen({
    super.key,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text("Welcome Screen"),
      ),
    );
  }
}