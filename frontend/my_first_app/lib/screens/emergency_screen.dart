import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class EmergencyScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children;
  final AppTheme T;
  const EmergencyScreen(
      {super.key, required this.go, required this.children, required this.T});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _adding = false;
  final List<Map<String, String>> _custom = [];

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    final childrenWithTeacher =
        widget.children.where((c) => c.teacherName.isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(children: [
        KCTopBar(
          title: 'Emergency Contacts',
          sub: 'SOS alert recipients',
          onBack: () => widget.go('dashboard'),
          T: T,
          rightEl: GestureDetector(
            onTap: () => setState(() => _adding = !_adding),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: T.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.red)),
              child: Text('+ Add',
                  style: TextStyle(
                      color: T.red, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: T.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: T.orange.withOpacity(0.25))),
          child: Row(children: [
            const Text('ℹ️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'These contacts are notified when an SOS alert is triggered. Police (119) is always included.',
                    style:
                        TextStyle(color: T.sub, fontSize: 11, height: 1.65))),
          ]),
        ),
        if (_adding) ...[
          _CustomContactForm(
              T: T,
              onSave: (c) {
                setState(() {
                  _custom.add(c);
                  _adding = false;
                });
              },
              onCancel: () => setState(() => _adding = false)),
          const SizedBox(height: 8),
        ],
        Text('EMERGENCY SERVICES',
            style: TextStyle(
                color: T.sub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        _EmergencyContactCard(
          avatar: '👮',
          name: 'Police Emergency',
          role: 'Emergency Services',
          phone: '119',
          color: T.red,
          pinned: true,
          T: T,
        ),
        const SizedBox(height: 16),
        if (childrenWithTeacher.isNotEmpty) ...[
          ...childrenWithTeacher.map((child) {
            final childColor = Color(child.colorHex);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        color: childColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: childColor, width: 1.5)),
                    child: Center(
                        child: Text(child.avatar,
                            style: const TextStyle(fontSize: 12))),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    "${child.name.toUpperCase()}'S TEACHER",
                    style: TextStyle(
                        color: T.sub,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1),
                  ),
                ]),
                const SizedBox(height: 8),
                _EmergencyContactCard(
                  avatar: '🧑‍🏫',
                  name: child.teacherName,
                  role: '${child.school} · ${child.name}\'s Class Teacher',
                  phone: child.teacherPhone.isEmpty
                      ? 'No phone number'
                      : child.teacherPhone,
                  color: childColor,
                  pinned: false,
                  T: T,
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
        ] else if (widget.children.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: T.border)),
            child: Row(children: [
              const Text('🧑‍🏫', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('No teachers added yet',
                        style: TextStyle(
                            color: T.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    Text('Add a teacher\'s contact in Manage Children → Edit.',
                        style: TextStyle(color: T.sub, fontSize: 11)),
                  ])),
              GestureDetector(
                onTap: () => widget.go('managechild'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: T.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: T.cyan.withOpacity(0.3))),
                  child: Text('Manage ›',
                      style: TextStyle(
                          color: T.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],
        if (_custom.isNotEmpty) ...[
          Text('OTHER CONTACTS',
              style: TextStyle(
                  color: T.sub,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          ..._custom.map((c) => _EmergencyContactCard(
                avatar: '👤',
                name: c['name'] ?? '',
                role: c['rel'] ?? '',
                phone: c['phone'] ?? '',
                color: T.cyan,
                pinned: false,
                T: T,
                onDelete: () => setState(() => _custom.remove(c)),
              )),
        ],
      ]),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final String avatar, name, role, phone;
  final Color color;
  final bool pinned;
  final AppTheme T;
  final VoidCallback? onDelete;
  const _EmergencyContactCard({
    required this.avatar,
    required this.name,
    required this.role,
    required this.phone,
    required this.color,
    required this.pinned,
    required this.T,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: pinned ? color.withOpacity(0.4) : T.border,
            width: pinned ? 1.5 : 1),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35), width: 2)),
          child:
              Center(child: Text(avatar, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
                child: Text(name,
                    style: TextStyle(
                        color: T.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700))),
            if (pinned) ...[
              const SizedBox(width: 6),
              Pill(text: 'Always', color: T.red)
            ],
          ]),
          Text(role, style: TextStyle(color: T.sub, fontSize: 11)),
          const SizedBox(height: 2),
          Text(phone,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ])),
        Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: T.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: T.green.withOpacity(0.27))),
            child:
                const Center(child: Text('📞', style: TextStyle(fontSize: 14))),
          ),
          if (onDelete != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: T.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.red.withOpacity(0.27))),
                child: Center(
                    child: Icon(Icons.delete_outline, color: T.red, size: 14)),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _CustomContactForm extends StatefulWidget {
  final AppTheme T;
  final Function(Map<String, String>) onSave;
  final VoidCallback onCancel;
  const _CustomContactForm(
      {required this.T, required this.onSave, required this.onCancel});
  @override
  State<_CustomContactForm> createState() => _CustomContactFormState();
}

class _CustomContactFormState extends State<_CustomContactForm> {
  final _name = TextEditingController();
  final _rel = TextEditingController();
  final _phone = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _rel.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: T.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: T.red.withOpacity(0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('➕ New Contact',
            style: TextStyle(
                color: T.red, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        KCInput(
            label: 'Full Name',
            placeholder: 'Contact name',
            icon: '👤',
            controller: _name,
            T: T),
        KCInput(
            label: 'Relationship',
            placeholder: 'e.g. Uncle, Doctor',
            icon: '🔗',
            controller: _rel,
            T: T),
        KCInput(
            label: 'Phone Number',
            placeholder: '+94 7X XXX XXXX',
            icon: '📱',
            controller: _phone,
            T: T,
            keyboardType: TextInputType.phone),
        Row(children: [
          Expanded(
              child: PrimaryBtn(
                  label: 'Save',
                  onTap: () {
                    if (_name.text.isNotEmpty && _phone.text.isNotEmpty) {
                      widget.onSave({
                        'name': _name.text,
                        'rel': _rel.text,
                        'phone': _phone.text
                      });
                    }
                  },
                  T: T,
                  danger: true)),
          const SizedBox(width: 8),
          Expanded(
              child: PrimaryBtn(
                  label: 'Cancel', onTap: widget.onCancel, T: T, ghost: true)),
        ]),
      ]),
    );
  }
}

class NotifPrefScreen extends StatefulWidget {
  final Function(String) go;
  final AppTheme T;
  const NotifPrefScreen({super.key, required this.go, required this.T});

  @override
  State<NotifPrefScreen> createState() => _NotifPrefScreenState();
}

class _NotifPrefScreenState extends State<NotifPrefScreen> {
  final _prefs = {
    'sos': true,
    'geo': true,
    'bat': true,
    'route': true,
    'act': false,
    'weekly': false,
    'band': true
  };

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    final groups = [
      {
        'title': '🚨 Safety',
        'items': [
          {
            'key': 'sos',
            'label': 'SOS Button Pressed',
            'desc': 'Immediate alert',
            'urgent': true
          },
          {
            'key': 'geo',
            'label': 'Geofence Alert',
            'desc': 'Zone entry / exit',
            'urgent': true
          },
        ],
      },
      {
        'title': '⌚ Device',
        'items': [
          {
            'key': 'bat',
            'label': 'Low Battery',
            'desc': 'Below 20%',
            'urgent': false
          },
          {
            'key': 'band',
            'label': 'Band Disconnected',
            'desc': 'Connection lost',
            'urgent': false
          },
        ],
      },
      {
        'title': '📊 Activity',
        'items': [
          {
            'key': 'route',
            'label': 'Route Completed',
            'desc': 'Child arrived safely',
            'urgent': false
          },
          {
            'key': 'act',
            'label': 'Activity Goals',
            'desc': 'Step milestones',
            'urgent': false
          },
          {
            'key': 'weekly',
            'label': 'Weekly Report',
            'desc': 'Every Sunday',
            'urgent': false
          },
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KCTopBar(
              title: 'Notification Settings',
              sub: 'Alert preferences',
              onBack: () => widget.go('settings'),
              T: T),
          // Methods
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
                color: T.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: T.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alert Methods',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final m in [
                      ['📱', 'Push', true],
                      ['💬', 'SMS', true],
                      ['📧', 'Email', false]
                    ])
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: m[0] != '📧' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: m[2] as bool
                                ? T.cyan.withOpacity(0.08)
                                : T.card2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: m[2] as bool ? T.cyan : T.border,
                                width: 1.5),
                          ),
                          child: Column(children: [
                            Text(m[0] as String,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(m[1] as String,
                                style: TextStyle(
                                    color: m[2] as bool ? T.cyan : T.sub,
                                    fontSize: 11,
                                    fontWeight: m[2] as bool
                                        ? FontWeight.w700
                                        : FontWeight.w400)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          for (final group in groups) ...[
            Text((group['title'] as String).toUpperCase(),
                style: TextStyle(
                    color: T.sub,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: T.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: T.border)),
              child: Column(
                children: (group['items'] as List).asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value as Map;
                  final isLast = i == (group['items'] as List).length - 1;
                  final urgent = item['urgent'] as bool;
                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(children: [
                                Text(item['label'] as String,
                                    style: TextStyle(
                                        color: T.text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                if (urgent) ...[
                                  const SizedBox(width: 6),
                                  Pill(text: 'Urgent', color: T.red)
                                ],
                              ]),
                              Text(item['desc'] as String,
                                  style: TextStyle(color: T.sub, fontSize: 11)),
                            ])),
                        KCToggle(
                          on: _prefs[item['key'] as String]!,
                          onToggle: () => setState(() =>
                              _prefs[item['key'] as String] =
                                  !_prefs[item['key'] as String]!),
                          color: urgent ? T.red : T.cyan,
                          T: T,
                        ),
                      ]),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          color: T.border,
                          indent: 14,
                          endIndent: 14),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
