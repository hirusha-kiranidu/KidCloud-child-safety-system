import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'models.dart';
import 'services/api_service.dart';
import 'utils/session_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/onboard_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/map_screen.dart';
import 'screens/notifs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/safezone_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/route_screen.dart';
import 'screens/add_child_screen.dart';
import 'screens/manage_children_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/otp_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const KidCloudApp());
}

class KidCloudApp extends StatefulWidget {
  const KidCloudApp({super.key});
  @override
  State<KidCloudApp> createState() => _KidCloudAppState();
}

class _KidCloudAppState extends State<KidCloudApp> {
  bool   _dark     = false;
  String _screen   = 'splash';
  ChildModel? _activeChild;
  List<ChildModel> _children = List.from(kidsData);
  String _otpPhone = '';

  // ── Zones shared across TrackingScreen + SafeZoneScreen ──
  List<ZoneModel> _zones = [];

  void _go(String screen) => setState(() => _screen = screen);
  void _setChild(ChildModel c) => setState(() => _activeChild = c);

  Future<void> _loadChildren() async {
    final result = await ApiService.fetchChildren();
    if (result.success && result.data!.isNotEmpty) {
      setState(() => _children = result.data!);
    }
  }

  Future<void> _addChild(Map data) async {
    final newChild = ChildModel(
      id:           DateTime.now().millisecondsSinceEpoch,
      name:         data['name']         ?? 'New Child',
      age:          data['age']          ?? 8,
      avatar:       data['avatar']       ?? '🧒',
      colorHex:     data['colorHex']     ?? 0xFF00E5C8,
      battery:      100,
      steps:        0,
      status:       'At Home',
      last:         'Just added',
      school:       data['school']       ?? '—',
      device:       data['device']       ?? '—',
      online:       false,
      teacherName:  data['teacherName']  ?? '',
      teacherPhone: data['teacherPhone'] ?? '',
      parentPhone:  data['parentPhone']  ?? '',
      gender:       data['gender']       ?? '',
    );
    setState(() => _children.add(newChild));
    await ApiService.addChild(newChild.toJson());
    await _loadChildren();
  }

  void _editChild(ChildModel updated) {
    setState(() {
      final idx = _children.indexWhere((c) => c.id == updated.id);
      if (idx != -1) _children[idx] = updated;
    });
  }

  void _deleteChild(int id) {
    setState(() {
      _children.removeWhere((c) => c.id == id);
      _zones.removeWhere((z) => z.childId == id);
    });
  }

  void _addZone(ZoneModel zone) {
    setState(() => _zones.add(zone));
  }

  void _updateZone(ZoneModel zone) {
    setState(() {
      final idx = _zones.indexWhere((z) => z.id == zone.id);
      if (idx != -1) _zones[idx] = zone;
    });
  }

  void _deleteZone(int id) {
    setState(() => _zones.removeWhere((z) => z.id == id));
  }

  Future<void> _logout() async {
    await ApiService.logout();
    setState(() {
      _screen      = 'welcome';
      _children    = List.from(kidsData);
      _activeChild = null;
      _zones       = [];
    });
  }

  AppTheme get T => _dark ? darkTheme : lightTheme;

  static const _navScreens = {'dashboard', 'map', 'notifs', 'settings'};
  static const _noHeaderScreens = {
    'splash', 'onboard0', 'onboard1', 'onboard2',
    'welcome', 'login', 'signup', 'otp',
    'map', 'tracking',
  };

  bool get _showNav    => _navScreens.contains(_screen);
  bool get _showHeader => !_noHeaderScreens.contains(_screen);

  Widget _buildScreen() {
    switch (_screen) {
      case 'splash':   return SplashScreen(go: _go, T: T);
      case 'onboard0': return OnboardScreen(idx: 0, go: _go, T: T);
      case 'onboard1': return OnboardScreen(idx: 1, go: _go, T: T);
      case 'onboard2': return OnboardScreen(idx: 2, go: _go, T: T);
      case 'welcome':  return WelcomeScreen(go: _go, T: T);
      case 'signup':   return SignupScreen(go: _go, T: T);
      case 'login':    return LoginScreen(go: _go, T: T);
      case 'otp':      return OtpScreen(go: _go, phoneNumber: _otpPhone);
      case 'dashboard':
        return DashboardScreen(
          go: (s) async {
            if (s == 'dashboard') await _loadChildren();
            _go(s);
          },
          setChild: _setChild,
          children: _children,
          T: T,
        );
      case 'map':
        return MapScreen(
          activeChild: _activeChild,
          children: _children,
          zones: _zones,
          onAddZone: _addZone,
          go: _go,
          T: T,
        );
      case 'tracking':
        return TrackingScreen(
          child: _activeChild,
          children: _children,
          zones: _zones,
          onAddZone: _addZone,
          go: _go,
          T: T,
        );
      case 'notifs':
        return NotifsScreen(go: _go, children: _children, T: T);
      case 'alerthistory':
        return AlertHistoryScreen(go: _go, T: T);
      case 'settings':
        return SettingsScreen(
          go: _go,
          dark: _dark,
          toggleDark: () => setState(() => _dark = !_dark),
          onLogout: _logout,
          T: T,
        );
      case 'safezone':
        return SafeZoneScreen(
          go: _go,
          children: _children,
          zones: _zones,
          onAddZone: _addZone,
          onUpdateZone: _updateZone,
          onDeleteZone: _deleteZone,
          T: T,
        );
      case 'sos':
        return SOSScreen(go: _go, children: _children, T: T);
      case 'route':
        return RouteScreen(go: _go, T: T);
      case 'addchild':
        return AddChildScreen(go: _go, onAdd: _addChild, T: T);
      case 'managechild':
        return ManageChildScreen(
          go: _go,
          children: _children,
          onEdit: _editChild,
          onDelete: _deleteChild,
          T: T,
        );
      // connectdevice route removed — not used in UI
      case 'emergency':
        return EmergencyScreen(go: _go, children: _children, T: T);
      case 'notifpref':
        return NotifPrefScreen(go: _go, T: T);
      default:
        return DashboardScreen(
          go: _go,
          setChild: _setChild,
          children: _children,
          T: T,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidCloud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: _dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: T.bg,
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _dark 
                ? [const Color(0xFF060B14), const Color(0xFF1A112A), const Color(0xFF060B14)]
                : [const Color(0xFFE8F4FF), const Color(0xFFFFEAD5), const Color(0xFFE8F4FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (_showHeader)
                  _AppHeader(
                    T: T,
                    dark: _dark,
                    onToggleDark: () => setState(() => _dark = !_dark),
                  ),
                Expanded(child: _buildScreen()),
                if (_showNav)
                  _BottomNav(screen: _screen, go: _go, T: T),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── App Header ─────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final AppTheme T;
  final bool dark;
  final VoidCallback onToggleDark;
  const _AppHeader(
      {required this.T, required this.dark, required this.onToggleDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: T.bg,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(children: [
        // ── Logo ────────────────────────────────────────
        Image.asset(
          'assets/images/logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5),
            children: [
              TextSpan(text: 'Kid',   style: TextStyle(color: T.text)),
              TextSpan(text: 'Cloud', style: TextStyle(color: T.cyan)),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onToggleDark,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: T.card2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: T.border),
            ),
            child: Text(dark ? '☀️' : '🌙',
                style: const TextStyle(fontSize: 13)),
          ),
        ),
      ]),
    );
  }
}

// ── Bottom Navigation Bar ──────────────────────────────────
class _BottomNav extends StatelessWidget {
  final String screen;
  final Function(String) go;
  final AppTheme T;
  const _BottomNav(
      {required this.screen, required this.go, required this.T});

  static const _tabs = [
    ('dashboard', Icons.home_rounded,          Icons.home_outlined,          'Home'),
    ('map',       Icons.location_on_rounded,   Icons.location_on_outlined,   'Map'),
    ('notifs',    Icons.notifications_rounded, Icons.notifications_outlined, 'Alerts'),
    ('settings',  Icons.settings_rounded,      Icons.settings_outlined,      'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: T.surface,
        border: Border(top: BorderSide(color: T.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((tab) {
          final (id, filledIcon, outlineIcon, label) = tab;
          final active = screen == id;
          return Expanded(
            child: GestureDetector(
              onTap: () => go(id),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? T.cyan.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      active ? filledIcon : outlineIcon,
                      color: active ? T.cyan : T.sub,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: active ? T.cyan : T.sub,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
