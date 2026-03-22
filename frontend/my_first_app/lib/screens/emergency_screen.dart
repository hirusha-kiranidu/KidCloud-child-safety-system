import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models.dart';

class EmergencyScreen extends StatefulWidget {
  final Function(String) go;
  final List<ChildModel> children;
  final AppTheme T;

  const EmergencyScreen({
    super.key,
    required this.go,
    required this.children,
    required this.T,
  });

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _adding = false;
  final List<Map<String, String>> _custom = [];

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    final childrenWithTeacher = widget.children
        .where((c) => c.teacherName.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          KCTopBar(
            title: 'Emergency Contacts',
            sub: 'SOS alert recipients',
            onBack: () => widget.go('dashboard'),
            T: T,
            rightEl: GestureDetector(
              onTap: () => setState(() => _adding = !_adding),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: T.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.red),
                ),
                child: Text(
                  '+ Add',
                  style: TextStyle(
                    color: T.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: T.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: T.orange.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These contacts are notified when an SOS alert is triggered. Police (119) is always included.',
                    style: TextStyle(color: T.sub, fontSize: 11, height: 1.65),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'EMERGENCY SERVICES',
            style: TextStyle(
              color: T.sub,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
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
          if (_adding) ...[
            _CustomContactForm(
              T: T,
              onSave: (c) {
                setState(() {
                  _custom.add(c);
                  _adding = false;
                });
              },
              onCancel: () => setState(() => _adding = false),
            ),
            const SizedBox(height: 8),
          ],
          if (childrenWithTeacher.isNotEmpty) ...[
            ...childrenWithTeacher.map((child) {
              final childColor = Color(child.colorHex);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: childColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: childColor, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            child.avatar,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        "${child.name.toUpperCase()}'S TEACHER",
                        style: TextStyle(
                          color: T.sub,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
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
                border: Border.all(color: T.border),
              ),
              child: Row(
                children: [
                  const Text('🧑‍🏫', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No teachers added yet',
                          style: TextStyle(
                            color: T.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Add a teacher\'s contact in Manage Children → Edit.',
                          style: TextStyle(color: T.sub, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.go('managechild'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: T.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: T.cyan.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Manage ›',
                        style: TextStyle(
                          color: T.cyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_custom.isNotEmpty) ...[
            Text(
              'OTHER CONTACTS',
              style: TextStyle(
                color: T.sub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            ..._custom.map(
              (c) => _EmergencyContactCard(
                avatar: '👤',
                name: c['name'] ?? '',
                role: c['rel'] ?? '',
                phone: c['phone'] ?? '',
                color: T.cyan,
                pinned: false,
                T: T,
                onDelete: () => setState(() => _custom.remove(c)),
              ),
            ),
          ],
        ],
      ),
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
          width: pinned ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.35), width: 2),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: T.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (pinned) ...[
                      const SizedBox(width: 6),
                      Pill(text: 'Always', color: T.red),
                    ],
                  ],
                ),
                Text(role, style: TextStyle(color: T.sub, fontSize: 11)),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: T.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: T.red.withOpacity(0.27)),
                ),
                child: Center(
                  child: Icon(Icons.delete_outline, color: T.red, size: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomContactForm extends StatefulWidget {
  final AppTheme T;
  final Function(Map<String, String>) onSave;
  final VoidCallback onCancel;

  const _CustomContactForm({
    required this.T,
    required this.onSave,
    required this.onCancel,
  });

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
        border: Border.all(color: T.red.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '➕ New Contact',
            style: TextStyle(
              color: T.red,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          KCInput(
            label: 'Full Name',
            placeholder: 'Contact name',
            icon: '👤',
            controller: _name,
            T: T,
          ),
          KCInput(
            label: 'Relationship',
            placeholder: 'e.g. Uncle, Doctor',
            icon: '🔗',
            controller: _rel,
            T: T,
          ),
          KCInput(
            label: 'Phone Number',
            placeholder: '+94 7X XXX XXXX',
            icon: '📱',
            controller: _phone,
            T: T,
            keyboardType: TextInputType.phone,
          ),
          Row(
            children: [
              Expanded(
                child: PrimaryBtn(
                  label: 'Save',
                  onTap: () {
                    if (_name.text.isNotEmpty && _phone.text.isNotEmpty) {
                      widget.onSave({
                        'name': _name.text,
                        'rel': _rel.text,
                        'phone': _phone.text,
                      });
                    }
                  },
                  T: T,
                  danger: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryBtn(
                  label: 'Cancel',
                  onTap: widget.onCancel,
                  T: T,
                  ghost: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
