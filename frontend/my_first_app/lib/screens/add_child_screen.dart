import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AddChildScreen extends StatefulWidget {
  final Function(String) go;
  final Function(Map) onAdd;
  final AppTheme T;

  const AddChildScreen({
    super.key,
    required this.go,
    required this.onAdd,
    required this.T,
  });

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          // 🔹 Top Bar
          KCTopBar(
            title: 'Add Child Profile',
            sub: 'Step $_step of 3',
            onBack: () {
              if (_step == 1) {
                widget.go('dashboard');
              } else {
                setState(() => _step--);
              }
            },
            T: T,
          ),

          const SizedBox(height: 20),

          // 🔹 Step Indicator (Basic)
          Row(
            children: List.generate(3, (i) {
              final isActive = i == _step - 1;

              return Expanded(
                child: Container(
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive ? T.cyan : T.card2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: T.border),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.black : T.sub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // 🔹 Placeholder Content (will be replaced in next commits)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: T.card2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: T.border),
            ),
            child: Column(
              children: [
                Text(
                  'Step $_step Content',
                  style: TextStyle(
                    color: T.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This section will be implemented in upcoming commits.',
                  style: TextStyle(color: T.sub, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Navigation Button
          ElevatedButton(
            onPressed: () {
              if (_step < 3) {
                setState(() => _step++);
              } else {
                widget.go('dashboard');
              }
            },
            child: Text(_step < 3 ? 'Next →' : 'Finish'),
          ),
        ],
      ),
    );
  }
}
