import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String) go;
  final bool dark;
  final VoidCallback toggleDark;
  final VoidCallback onLogout;
  final AppTheme T;
  const SettingsScreen(
      {super.key,
      required this.go,
      required this.dark,
      required this.toggleDark,
      required this.onLogout,
      required this.T});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _vibrate = true;

  String _displayName = 'Cresida Lakmini';
  String _displayEmail = 'lakminiparanagamage72@gmail.com';
  String _displayPhone = '+94 71 7723262';

  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Settings',
            style: TextStyle(
                color: T.text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),

        // ── Profile card ───────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [T.card, T.card2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: T.border),
          ),
          child: Row(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: T.cyan.withOpacity(0.13),
                  shape: BoxShape.circle,
                  border: Border.all(color: T.cyan, width: 2.5)),
              child: const Center(
                  child: Text('👨', style: TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_displayName,
                      style: TextStyle(
                          color: T.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text(_displayEmail,
                      style: TextStyle(color: T.sub, fontSize: 12)),
                  Text(_displayPhone,
                      style: TextStyle(color: T.sub, fontSize: 11)),
                ])),
            GestureDetector(
              onTap: () => _showEditProfile(context, T),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                    color: T.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.cyan.withOpacity(0.4))),
                child: Text('Edit',
                    style: TextStyle(
                        color: T.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Appearance ──────────────────────────────────
        _SectionHeader('Appearance', T: T),
        _SettingsGroup(T: T, children: [
          _ToggleRow(
              icon: widget.dark ? '🌙' : '☀️',
              title: 'Dark Mode',
              sub: 'Switch app appearance',
              on: widget.dark,
              onToggle: widget.toggleDark,
              T: T),
        ]),

        // ── Sound & Vibration ──────────────────────────
        _SectionHeader('Sound & Vibration', T: T),
        _SettingsGroup(T: T, children: [
          _ToggleRow(
              icon: '🔊',
              title: 'Alert Sounds',
              sub: 'Play sounds for notifications',
              on: _sound,
              onToggle: () => setState(() => _sound = !_sound),
              T: T),
          _Divider(T: T),
          _ToggleRow(
              icon: '📳',
              title: 'Vibration',
              sub: 'Vibrate on alerts',
              on: _vibrate,
              onToggle: () => setState(() => _vibrate = !_vibrate),
              T: T),
        ]),

        // ── Account ────────────────────────────────────
        _SectionHeader('Account', T: T),
        _SettingsGroup(T: T, children: [
          _NavRow(
              icon: '👤',
              title: 'Edit Profile',
              sub: 'Update your name, email & phone',
              onTap: () => _showEditProfile(context, T),
              T: T),
          _Divider(T: T),
          _NavRow(
              icon: '🔑',
              title: 'Change Password',
              sub: 'Update your password',
              onTap: () => _showChangePassword(context, T),
              T: T),
          _Divider(T: T),
          _NavRow(
              icon: '🗑️',
              title: 'Delete Account',
              sub: 'Permanently remove your account',
              onTap: () => _confirmDelete(context, T),
              T: T,
              danger: true),
        ]),

        // ── Help & Support ─────────────────────────────
        _SectionHeader('Help & Support', T: T),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: T.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: T.border)),
          child: Column(children: [
            _NavRow(
                icon: '❓',
                title: 'FAQ',
                sub: 'Frequently asked questions',
                onTap: () => _showFAQ(context, T),
                T: T),
            _Divider(T: T),
            _NavRow(
                icon: '💬',
                title: 'Contact Support',
                sub: 'Get help from our team',
                onTap: () => _showContactSupport(context, T),
                T: T),
            _Divider(T: T),
            _NavRow(
                icon: '⚠️',
                title: 'Report a Problem',
                sub: 'Tell us what went wrong',
                onTap: () => _showReportForm(context, T),
                T: T),
            _Divider(T: T),
            _NavRow(
                icon: '⭐',
                title: 'Feedback',
                sub: 'Rate the app or send suggestions',
                onTap: () => _showFeedbackForm(context, T),
                T: T),
          ]),
        ),

        const SizedBox(height: 4),
        GestureDetector(
          onTap: widget.onLogout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: T.red.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: T.red.withOpacity(0.35)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout_rounded, color: T.red, size: 18),
              const SizedBox(width: 8),
              Text('Sign Out',
                  style: TextStyle(
                      color: T.red, fontSize: 14, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Edit Profile ───────────────────────────────────────
  void _showEditProfile(BuildContext ctx, AppTheme T) {
    final nameCtrl = TextEditingController(text: _displayName);
    final emailCtrl = TextEditingController(text: _displayEmail);
    final phoneCtrl = TextEditingController(text: _displayPhone);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
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
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Edit Profile',
                  style: TextStyle(
                      color: T.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              KCInput(
                  label: 'Full Name',
                  placeholder: 'Your name',
                  icon: '👤',
                  controller: nameCtrl,
                  T: T),
              KCInput(
                  label: 'Email Address',
                  placeholder: 'you@email.com',
                  icon: '✉️',
                  controller: emailCtrl,
                  T: T,
                  keyboardType: TextInputType.emailAddress),
              KCInput(
                  label: 'Phone Number',
                  placeholder: '+94 7X XXX XXXX',
                  icon: '📱',
                  controller: phoneCtrl,
                  T: T,
                  keyboardType: TextInputType.phone),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: T.cyan.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: T.cyan.withOpacity(0.2))),
                child: Row(children: [
                  Icon(Icons.info_outline_rounded, color: T.cyan, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Saved locally. Will sync to server once backend is connected.',
                          style: TextStyle(color: T.sub, fontSize: 11))),
                ]),
              ),
              PrimaryBtn(
                  label: '💾 Save Changes',
                  T: T,
                  onTap: () {
                    // Save to local state — visible immediately across the app
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
                  }),
              const SizedBox(height: 20),
            ]),
      ),
    );
  }

  // ── Change Password ────────────────────────────────────
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setSt) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
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
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('Change Password',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                if (error != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: T.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: T.red.withOpacity(0.3))),
                    child: Row(children: [
                      Icon(Icons.error_outline_rounded, color: T.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(error!,
                              style: TextStyle(color: T.red, fontSize: 12))),
                    ]),
                  ),
                ],
                KCInput(
                    label: 'Current Password',
                    placeholder: 'Enter current password',
                    icon: '🔒',
                    controller: currentCtrl,
                    T: T,
                    obscure: true),
                KCInput(
                    label: 'New Password',
                    placeholder: 'Min 8 characters',
                    icon: '🔑',
                    controller: newCtrl,
                    T: T,
                    obscure: true),
                KCInput(
                    label: 'Confirm New',
                    placeholder: 'Re-enter new password',
                    icon: '🔐',
                    controller: confirmCtrl,
                    T: T,
                    obscure: true),
                PrimaryBtn(
                    label: '🔑 Update Password',
                    T: T,
                    onTap: () {
                      if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                        setSt(() => error = 'Please fill in all fields');
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        setSt(() => error = 'New passwords do not match');
                        return;
                      }
                      if (newCtrl.text.length < 6) {
                        setSt(() =>
                            error = 'Password must be at least 6 characters');
                        return;
                      }
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: const Text('Password updated successfully'),
                        backgroundColor: T.green,
                        behavior: SnackBarBehavior.floating,
                      ));
                      // TODO: ApiService.changePassword(current, newPass)
                    }),
                const SizedBox(height: 20),
              ]),
        ),
      ),
    );
  }

  // ── FAQ ────────────────────────────────────────────────
  void _showFAQ(BuildContext ctx, AppTheme T) {
    const faqs = [
      (
        'How does live tracking work?',
        'KidCloud uses GPS built into the wristband to continuously update your child\'s location. The location is sent to our servers every few seconds and displayed on the map in your app.'
      ),
      (
        'What happens when the SOS button is pressed?',
        'When your child presses the SOS button on their wristband, you will instantly receive a red emergency alert on your dashboard. Emergency contacts are also notified. The alert stays active until you mark it as resolved.'
      ),
      (
        'How do safe zones work?',
        'Safe zones are areas you define (like home or school). You add a starting point and ending point. If your child moves outside the defined zone, you will receive a push notification immediately.'
      ),
      (
        'What is Voice Detection?',
        'Voice Detection is a premium feature that uses the wristband\'s built-in microphone to listen for specific distress keywords. When a keyword is detected, you receive an alert and can optionally listen to a live audio feed.'
      ),
      (
        'How do I connect the wristband?',
        'Go to Connect Device from the dashboard. You can scan the QR code on the wristband box, or manually enter the Device ID printed on the back of the wristband.'
      ),
      (
        'How long does the battery last?',
        'The KidCloud wristband battery lasts approximately 12–18 hours on a single charge with GPS tracking active. Battery percentage is shown in the app. You will receive a low battery notification when it drops below 20%.'
      ),
      (
        'Can I add multiple children?',
        'Yes. You can add as many children as needed. Each child gets their own profile, device, safe zones, and tracking screen. Switch between children using the child picker on the map screen.'
      ),
      (
        'Is my data private?',
        'Yes. All location data is encrypted in transit and at rest. Only you (the registered parent) can see your children\'s data. We never share data with third parties.'
      ),
      (
        'What if the wristband loses GPS signal?',
        'If the wristband loses GPS signal, the last known location is shown on the map. You will see the "last seen" time update to reflect when data was last received. The device attempts to re-establish connection automatically.'
      ),
      (
        'How do I reset the wristband?',
        'Hold the SOS button for 10 seconds until the device vibrates. This performs a soft reset. For a factory reset, hold both the SOS button and power button together for 15 seconds.'
      ),
    ];

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: T.border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(children: [
              Icon(Icons.help_rounded, color: T.cyan, size: 22),
              const SizedBox(width: 10),
              Text('Frequently Asked Questions',
                  style: TextStyle(
                      color: T.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: faqs.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: T.border),
              itemBuilder: (_, i) =>
                  _FAQItem(q: faqs[i].$1, a: faqs[i].$2, T: T),
            ),
          ),
        ]),
      ),
    );
  }

  void _showContactSupport(BuildContext ctx, AppTheme T) {
    const members = [
      ('Sayuri Gunarathne', '0701396964', '👩', 'Team Leader & UI/UX Designer'),
      ('Binadi Laknara', '0707723262', '👩', 'Database & Cloud Engineer'),
      ('Wathmi Kodippili', '0721836359', '👩', 'Hardware & IoT Specialist'),
      ('Pasan Tharupathi', '0757707175', '👨', 'Backend Developer'),
      ('Hirusha Kiranidu', '0701507530', '👨', 'Frontend & Web Developer'),
      ('Rashmika Sewmini', '0753576012', '👩', 'Database & Cloud Engineer'),
    ];

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (_, ctrl) => Column(children: [
          Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: T.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.groups_rounded, color: T.cyan, size: 22),
                const SizedBox(width: 10),
                Text('Contact Support',
                    style: TextStyle(
                        color: T.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 4),
              Text('KidCloud Team CS-84 · IIT / University of Westminster',
                  style: TextStyle(color: T.sub, fontSize: 12)),
            ]),
          ),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: members.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: T.border),
              itemBuilder: (_, i) {
                final (name, tel, avatar, role) = members[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          color: T.cyan.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: T.cyan.withOpacity(0.3))),
                      child: Center(
                          child: Text(avatar,
                              style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(name,
                              style: TextStyle(
                                  color: T.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Text(role,
                              style: TextStyle(color: T.sub, fontSize: 11)),
                          const SizedBox(height: 2),
                          Row(children: [
                            Icon(Icons.phone_rounded, color: T.cyan, size: 13),
                            const SizedBox(width: 4),
                            Text(tel,
                                style: TextStyle(
                                    color: T.cyan,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ])),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: T.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: T.green.withOpacity(0.3))),
                      child: Icon(Icons.call_rounded, color: T.green, size: 18),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _showReportForm(BuildContext ctx, AppTheme T) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: T.border,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Icon(Icons.bug_report_rounded, color: T.orange, size: 22),
            const SizedBox(width: 8),
            Text('Report a Problem',
                style: TextStyle(
                    color: T.text, fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: T.card2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: T.border)),
            child: TextField(
              controller: ctrl,
              maxLines: 5,
              style: TextStyle(color: T.text, fontSize: 13),
              decoration: InputDecoration(
                  hintText: 'Describe the problem you encountered…',
                  hintStyle: TextStyle(color: T.muted, fontSize: 13),
                  border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryBtn(
              label: '📤 Send Report',
              T: T,
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: const Text('Report submitted. Thank you!'),
                    backgroundColor: T.green,
                    behavior: SnackBarBehavior.floating));
              }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ── Feedback ───────────────────────────────────────────
  void _showFeedbackForm(BuildContext ctx, AppTheme T) {
    int stars = 5;
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: T.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
          builder: (ctx2, setSt) => Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 20,
                    right: 20,
                    top: 20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: T.border,
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text('Send Feedback',
                      style: TextStyle(
                          color: T.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              5,
                              (i) => GestureDetector(
                                    onTap: () => setSt(() => stars = i + 1),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Icon(
                                            i < stars
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: T.orange,
                                            size: 38)),
                                  )))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: T.card2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: T.border)),
                    child: TextField(
                      controller: ctrl,
                      maxLines: 4,
                      style: TextStyle(color: T.text, fontSize: 13),
                      decoration: InputDecoration(
                          hintText: 'Share your thoughts…',
                          hintStyle: TextStyle(color: T.muted, fontSize: 13),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryBtn(
                      label: '⭐ Submit Feedback',
                      T: T,
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: const Text('Thank you for your feedback!'),
                            backgroundColor: T.green,
                            behavior: SnackBarBehavior.floating));
                      }),
                  const SizedBox(height: 20),
                ]),
              )),
    );
  }

  // ── Delete Account ────────────────────────────────────
  void _confirmDelete(BuildContext ctx, AppTheme T) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: T.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Account?',
            style: TextStyle(color: T.text, fontWeight: FontWeight.w700)),
        content: Text(
            'This will permanently delete your account and all tracking data. This cannot be undone.',
            style: TextStyle(color: T.sub, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: T.sub))),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onLogout();
              },
              child: Text('Delete',
                  style: TextStyle(color: T.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

// ── FAQ expandable item ────────────────────────────────────
class _FAQItem extends StatefulWidget {
  final String q, a;
  final AppTheme T;
  const _FAQItem({required this.q, required this.a, required this.T});
  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final T = widget.T;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(widget.q,
                    style: TextStyle(
                        color: T.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Icon(
                _open
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: T.sub,
                size: 20),
          ]),
          if (_open) ...[
            const SizedBox(height: 8),
            Text(widget.a,
                style: TextStyle(color: T.sub, fontSize: 12, height: 1.6)),
          ],
        ]),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final AppTheme T;
  const _SectionHeader(this.title, {required this.T});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                color: T.sub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
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
            border: Border.all(color: T.border)),
        child: Column(children: children),
      );
}

class _NavRow extends StatelessWidget {
  final String icon, title, sub;
  final VoidCallback onTap;
  final AppTheme T;
  final bool danger;
  const _NavRow(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.onTap,
      required this.T,
      this.danger = false});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: danger
                        ? T.red.withOpacity(0.07)
                        : T.cyan.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                          color: danger ? T.red : T.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(sub, style: TextStyle(color: T.sub, fontSize: 11)),
                ])),
            Icon(Icons.chevron_right_rounded, color: T.sub, size: 20),
          ]),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  final String icon, title, sub;
  final bool on;
  final VoidCallback onToggle;
  final AppTheme T;
  const _ToggleRow(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.on,
      required this.onToggle,
      required this.T});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: T.cyan.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: T.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                if (sub.isNotEmpty)
                  Text(sub, style: TextStyle(color: T.sub, fontSize: 11)),
              ])),
          KCToggle(on: on, onToggle: onToggle, T: T),
        ]),
      );
}

class _Divider extends StatelessWidget {
  final AppTheme T;
  const _Divider({required this.T});
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: T.border, indent: 14, endIndent: 14);
}
