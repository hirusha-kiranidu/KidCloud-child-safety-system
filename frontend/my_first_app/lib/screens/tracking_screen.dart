import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models.dart';
import '../widgets/shared_widgets.dart';

class TrackingScreen extends StatelessWidget {
  final ChildModel? child;
  final Function(String) go;
  final AppTheme T;

  const TrackingScreen({
    super.key,
    this.child,
    required this.go,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
