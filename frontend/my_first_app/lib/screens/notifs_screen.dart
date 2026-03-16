import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class NotifsScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;

  const NotifsScreen({super.key, required this.go, required this.T});

  @override
  State<NotifsScreen> createState() => _NotifsScreenState();
}

class _NotifsScreenState extends State<NotifsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
