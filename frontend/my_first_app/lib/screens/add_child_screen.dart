import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

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
  final _parent = TextEditingController();
  final _emerg = TextEditingController();
  // ── NEW: teacher contact fields ──────────────────────────
  final _teacherName = TextEditingController();
  final _teacherPhone = TextEditingController();

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
    _parent.dispose();
    _emerg.dispose();
    _teacherName.dispose();
    _teacherPhone.dispose();
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
            onBack: () =>
                _step == 1 ? widget.go('dashboard') : setState(() => _step--),
            T: T,
          ),
          // Step indicator
          Row(
            children: List.generate(3, (i) {
              final active = i == _step - 1;
              final done = i < _step - 1;
              return Expanded(
                child: Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2.5,
                          color: i <= _step - 1 ? T.cyan : T.border,
                        ),
                      ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done || active ? T.cyan : T.card2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: done || active ? T.cyan : T.border,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          done ? '✓' : '${i + 1}',
                          style: TextStyle(
                            color: done || active ? Colors.black : T.sub,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (i < 2)
                      Expanded(
                        child: Container(
                          height: 2.5,
                          color: i < _step - 1 ? T.cyan : T.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // ── Step 1: Avatar + Name + Gender ────────────
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
            Text(
              'GENDER',
              style: TextStyle(
                color: T.sub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
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
            const SizedBox(height: 16),
            PrimaryBtn(
              label: 'Continue →',
              onTap: () => setState(() => _step = 2),
              T: T,
            ),

            // ── Step 2: School + Device ────────────────────
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
            PrimaryBtn(
              label: 'Continue →',
              onTap: () => setState(() => _step = 3),
              T: T,
            ),

            // ── Step 3: Contacts (parent + teacher + emerg) ─
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: T.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: T.blue.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Text('ℹ️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'These contacts will receive SOS alerts for this child.',
                      style: TextStyle(color: T.sub, fontSize: 12, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            KCInput(
              label: 'Parent Contact Number *',
              placeholder: '+94 7X XXX XXXX',
              icon: '📱',
              controller: _parent,
              T: T,
              keyboardType: TextInputType.phone,
            ),
            KCInput(
              label: 'Emergency Contact',
              placeholder: '+94 7X XXX XXXX',
              icon: '🚨',
              controller: _emerg,
              T: T,
              keyboardType: TextInputType.phone,
            ),
            // ── NEW teacher contact ──────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'TEACHER CONTACT',
                style: TextStyle(
                  color: T.sub,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            KCInput(
              label: "Teacher's Full Name",
              placeholder: 'e.g. Mrs. Silva',
              icon: '🧑‍🏫',
              controller: _teacherName,
              T: T,
            ),
            KCInput(
              label: "Teacher's Phone Number",
              placeholder: '+94 7X XXX XXXX',
              icon: '📞',
              controller: _teacherPhone,
              T: T,
              keyboardType: TextInputType.phone,
            ),

            // Summary
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16, top: 4),
              decoration: BoxDecoration(
                color: T.card2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: T.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUMMARY',
                    style: TextStyle(
                      color: T.sub,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final row in [
                    ['👤', 'Name', _name.text.isEmpty ? '—' : _name.text],
                    ['🔢', 'Age', _age.text.isEmpty ? '—' : _age.text],
                    ['🏫', 'School', _school.text.isEmpty ? '—' : _school.text],
                    [
                      '⌚',
                      'Device',
                      _device.text.isEmpty ? 'Not linked' : _device.text,
                    ],
                    [
                      '🧑‍🏫',
                      'Teacher',
                      _teacherName.text.isEmpty ? '—' : _teacherName.text,
                    ],
                  ]) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${row[0]} ${row[1]}',
                          style: TextStyle(color: T.sub, fontSize: 12),
                        ),
                        Text(
                          row[2],
                          style: TextStyle(
                            color: T.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 10, color: T.border),
                  ],
                ],
              ),
            ),
            PrimaryBtn(
              label: '✅ Save Child Profile',
              T: T,
              onTap: () {
                widget.onAdd({
                  'name': _name.text.isEmpty ? 'New Child' : _name.text,
                  'age': int.tryParse(_age.text) ?? 8,
                  'avatar': _avatar,
                  'colorHex': _colorHex,
                  'school': _school.text.isEmpty ? '—' : _school.text,
                  'device': _device.text.isEmpty ? '—' : _device.text,
                  'teacherName': _teacherName.text.trim(),
                  'teacherPhone': _teacherPhone.text.trim(),
                  'parentPhone': _parent.text.trim(),
                  'gender': _gender,
                });
                widget.go('dashboard');
              },
            ),
          ],
        ],
      ),
    );
  }
}
