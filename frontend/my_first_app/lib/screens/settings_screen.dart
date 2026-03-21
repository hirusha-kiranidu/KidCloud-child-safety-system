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

          _SectionHeader('Account', T: T),
          _SettingsGroup(
            T: T,
            children: [
              _NavRow(
                icon: '👤',
                title: 'Edit Profile',
                sub: 'Update your name, email & phone',
                onTap: () => _showEditProfile(context, T),
                T: T,
              ),
              _Divider(T: T),
              _NavRow(
                icon: '🔑',
                title: 'Change Password',
                sub: 'Update your password',
                onTap: () => _showChangePassword(context, T),
                T: T,
              ),
              _Divider(T: T),
              _NavRow(
                icon: '🗑️',
                title: 'Delete Account',
                sub: 'Permanently remove your account',
                onTap: () => _confirmDelete(context, T),
                T: T,
                danger: true,
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
          children: [
            const SizedBox(height: 16),
            KCInput(label: 'Full Name', icon: '👤', controller: nameCtrl, T: T),
            KCInput(
              label: 'Email Address',
              icon: '✉️',
              controller: emailCtrl,
              T: T,
            ),
            KCInput(
              label: 'Phone Number',
              icon: '📱',
              controller: phoneCtrl,
              T: T,
            ),
            PrimaryBtn(
              label: '💾 Save Changes',
              T: T,
              onTap: () {
                setState(() {
                  _displayName = nameCtrl.text;
                  _displayEmail = emailCtrl.text;
                  _displayPhone = phoneCtrl.text;
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

  void _showChangePassword(BuildContext ctx, AppTheme T) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setSt) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null) Text(error!, style: TextStyle(color: T.red)),

              KCInput(
                label: 'Current Password',
                icon: '🔒',
                controller: currentCtrl,
                T: T,
                obscure: true,
              ),
              KCInput(
                label: 'New Password',
                icon: '🔑',
                controller: newCtrl,
                T: T,
                obscure: true,
              ),
              KCInput(
                label: 'Confirm New',
                icon: '🔐',
                controller: confirmCtrl,
                T: T,
                obscure: true,
              ),

              PrimaryBtn(
                label: '🔑 Update Password',
                T: T,
                onTap: () {
                  if (newCtrl.text != confirmCtrl.text) {
                    setSt(() => error = 'Passwords do not match');
                    return;
                  }
                  Navigator.pop(ctx);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppTheme T) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: T.card,
        title: Text('Delete Account?', style: TextStyle(color: T.text)),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: T.sub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: Text('Delete', style: TextStyle(color: T.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppTheme T;

  const _SectionHeader(this.title, {required this.T});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(color: T.sub, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final AppTheme T;

  const _SettingsGroup({required this.children, required this.T});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: T.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: T.border),
    ),
    child: Column(children: children),
  );
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
  Widget build(BuildContext context) => Padding(
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
          child: Center(child: Text(icon)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: T.text)),
              Text(sub, style: TextStyle(color: T.sub, fontSize: 11)),
            ],
          ),
        ),
        KCToggle(on: on, onToggle: onToggle, T: T),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  final String icon, title, sub;
  final VoidCallback onTap;
  final AppTheme T;
  final bool danger;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    required this.T,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: danger
                  ? T.red.withOpacity(0.07)
                  : T.cyan.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(icon)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: danger ? T.red : T.text)),
                Text(sub, style: TextStyle(color: T.sub, fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: T.sub),
        ],
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  final AppTheme T;

  const _Divider({required this.T});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: T.border, indent: 14, endIndent: 14);
}
