import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) go;
  final bool dark;
  final VoidCallback toggleDark;
  final VoidCallback onLogout;
  final AppTheme T;

  const SettingsScreen({
    super.key,
    required this.go,
    required this.dark,
    required this.toggleDark,
    required this.onLogout,
    required this.T,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return