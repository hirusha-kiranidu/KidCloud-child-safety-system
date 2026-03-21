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
  bool _sound = true;
  bool _vibrate = true;

  String _displayName = 'Alex Johnson';
  String _displayEmail = 'alex@email.com';
  String _displayPhone = '+94 71 234 5678';

  @override
  Widget build(BuildContext context) {
    final T = widget.T;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: T.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [T.card, T.card2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: T.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: T.cyan.withOpacity(0.13),
                    shape: BoxShape.circle,
                    border: Border.all(color: T.cyan, width: 2.5),
                  ),
                  child: const Center(
                    child: Text('👨', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: TextStyle(
                          color: T.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _displayEmail,
                        style: TextStyle(color: T.sub, fontSize: 12),
                      ),
                      Text(
                        _displayPhone,
                        style: TextStyle(color: T.sub, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditProfile(context, T),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: T.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: T.cyan.withOpacity(0.4)),
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        color: T.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _SectionHeader('Appearance', T: T),

          _SettingsGroup(
            T: T,
            children: [
              _ToggleRow(
                icon: widget.dark ? '🌙' : '☀️',
                title: 'Dark Mode',
                sub: 'Switch app appearance',
                on: widget.dark,
                onToggle: widget.toggleDark,
                T: T,
              ),
            ],
          ),

          _SectionHeader('Sound & Vibration', T: T),

          _SettingsGroup(
            T: T,
            children: [
              _ToggleRow(
                icon: '🔊',
                title: 'Alert Sounds',
                sub: 'Play sounds for notifications',
                on: _sound,
                onToggle: () => setState(() => _sound = !_sound),
                T: T,
              ),
              _Divider(T: T),
              _ToggleRow(
                icon: '📳',
                title: 'Vibration',
                sub: 'Vibrate on alerts',
                on: _vibrate,
                onToggle: () => setState(() => _vibrate = !_vibrate),
                T: T,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext ctx, AppTheme T) {
    final nameCtrl = TextEditingController(text: _displayName);
    final emailCtrl = TextEditingController(text: _displayEmail);
    final phoneCtrl = TextEditingController(text: _displayPhone);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: T.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Edit Profile',
              style: TextStyle(
                color: T.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 16),

            KCInput(
              label: 'Full Name',
              placeholder: 'Your name',
              icon: '👤',
              controller: nameCtrl,
              T: T,
            ),

            KCInput(
              label: 'Email Address',
              placeholder: 'you@email.com',
              icon: '✉️',
              controller: emailCtrl,
              T: T,
              keyboardType: TextInputType.emailAddress,
            ),

            KCInput(
              label: 'Phone Number',
              placeholder: '+94 7X XXX XXXX',
              icon: '📱',
              controller: phoneCtrl,
              T: T,
              keyboardType: TextInputType.phone,
            ),

            PrimaryBtn(
              label: '💾 Save Changes',
              T: T,
              onTap: () {
                setState(() {
                  _displayName = nameCtrl.text.trim().isEmpty
                      ? _displayName
                      : nameCtrl.text.trim();
                  _displayEmail = emailCtrl.text.trim().isEmpty
                      ? _displayEmail
                      : emailCtrl.text.trim();
                  _displayPhone = phoneCtrl.text.trim().isEmpty
                      ? _displayPhone
                      : phoneCtrl.text.trim();
                });
                Navigator.pop(ctx);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppTheme T;

  const _SectionHeader(this.title, {required this.T});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: T.sub,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final AppTheme T;

  const _SettingsGroup({required this.children, required this.T});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: T.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String icon, title, sub;
  final bool on;
  final VoidCallback onToggle;
  final AppTheme T;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.on,
    required this.onToggle,
    required this.T,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: T.cyan.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: T.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(sub, style: TextStyle(color: T.sub, fontSize: 11)),
              ],
            ),
          ),
          KCToggle(on: on, onToggle: onToggle, T: T),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final AppTheme T;

  const _Divider({required this.T});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: T.border, indent: 14, endIndent: 14);
  }
}
