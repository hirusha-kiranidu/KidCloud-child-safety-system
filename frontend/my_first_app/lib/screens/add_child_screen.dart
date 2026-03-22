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

  String _avatar = '👧', _gender = 'Girl';
  int _colorHex = 0xFF00E5C8;

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _school = TextEditingController();
  final _device = TextEditingController();

  final _avs = ['👧', '👦', '🧒', '👶', '🧑'];
  final _cols = [
    0xFF00E5C8,
    0xFF2B7EFF,
    0xFF6366F1,
    0xFFFF6EB4,
    0xFF22D67A,
    0xFFFF7D3E,
  ];

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _school.dispose();
    _device.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
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

          if (_step == 1) ...[
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Color(_colorHex).withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(_colorHex), width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _avatar,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _avs
                        .map(
                          (a) => GestureDetector(
                            onTap: () => setState(() => _avatar = a),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _avatar == a
                                    ? Color(_colorHex).withOpacity(0.17)
                                    : T.card2,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _avatar == a
                                      ? Color(_colorHex)
                                      : T.border,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  a,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _cols
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setState(() => _colorHex = c),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Color(c),
                                shape: BoxShape.circle,
                                border: _colorHex == c
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            KCInput(
              label: "Child's Full Name *",
              placeholder: 'e.g. Emma Johnson',
              icon: '👤',
              controller: _name,
              T: T,
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Girl', 'Boy', 'Other']
                  .map(
                    (g) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _gender = g),
                        child: Container(
                          margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _gender == g
                                ? T.cyan.withOpacity(0.11)
                                : T.card2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _gender == g ? T.cyan : T.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            g,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _gender == g ? T.cyan : T.sub,
                              fontSize: 13,
                              fontWeight: _gender == g
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ] else if (_step == 2) ...[
            KCInput(
              label: 'Age *',
              placeholder: 'e.g. 9',
              icon: '🔢',
              controller: _age,
              T: T,
              keyboardType: TextInputType.number,
            ),
            KCInput(
              label: 'School / Institution *',
              placeholder: 'e.g. Vidyalaya',
              icon: '🏫',
              controller: _school,
              T: T,
            ),
            KCInput(
              label: 'Device ID / Tracker ID',
              placeholder: 'e.g. KC-A2F3',
              icon: '⌚',
              controller: _device,
              T: T,
            ),
          ] else ...[
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
          ],

          const SizedBox(height: 20),

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
