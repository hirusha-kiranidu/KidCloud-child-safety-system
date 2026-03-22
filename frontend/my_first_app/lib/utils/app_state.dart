import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  List<ChildModel> children = List.from(kidsData);

  bool emergency = false;
  String emergencyChildName = '';

  int unreadAlerts = 2;

  Timer? _locationTimer;

  double _mockLat = 7.2906;
  double _mockLng = 80.6337;

  AppState() {
    _startLocationPolling();
  }

  static AppState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppStateProviderState>()!.state;

  void addChild(ChildModel c) {
    children = [...children, c];
    notifyListeners();
  }

  void updateChild(ChildModel updated) {
    children = children.map((c) => c.id == updated.id ? updated : c).toList();
    notifyListeners();
  }

  void deleteChild(int id) {
    children = children.where((c) => c.id != id).toList();
    notifyListeners();
  }

  void triggerEmergency(String childName) {
    emergency = true;
    emergencyChildName = childName;
    notifyListeners();
  }

  void dismissEmergency() {
    emergency = false;
    emergencyChildName = '';
    notifyListeners();
  }

  void markAlertsRead() {
    unreadAlerts = 0;
    notifyListeners();
  }

  void addAlert() {
    unreadAlerts++;
    notifyListeners();
  }

  void _startLocationPolling() {
    _locationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _mockLat +=
          (0.001 - (0.002 * (0.5 - (DateTime.now().millisecond / 1000))));
      _mockLng += (0.001 - (0.002 * (0.5 - (DateTime.now().second / 60))));
      if (children.isNotEmpty) {
        final updated = children.first.copyWith(last: 'Just now');
        children = children
            .map((c) => c.id == updated.id ? updated : c)
            .toList();
        notifyListeners();
      }
    });
  }

  Future<void> loadFromBackend() async {
    final result = await ApiService.fetchChildren();
    if (result.success && result.data!.isNotEmpty) {
      children = result.data!;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}

class AppStateProvider extends StatefulWidget {
  final Widget child;
  const AppStateProvider({super.key, required this.child});

  @override
  State<AppStateProvider> createState() => _AppStateProviderState();
}

class _AppStateProviderState extends State<AppStateProvider> {
  final state = AppState();

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
