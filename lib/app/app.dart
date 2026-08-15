import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'theme.dart';
import 'splash_screen.dart';
import '../features/main_shell.dart';
import '../features/more/login_screen.dart';
import '../features/security/lock_screen.dart';
import '../features/security/lock_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.light;
  Locale _locale = const Locale('ar');

  @override
  void initState() {
    super.initState();
    _load();
    ThemeNotifier.listener = _load;
    LocaleNotifier.localeListener = _load;
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final dark = await ThemeNotifier.isDark();
    final lang = await LocaleNotifier.getCode();
    if (mounted) {
      setState(() {
        _mode = dark ? ThemeMode.dark : ThemeMode.light;
        _locale = Locale(lang);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حساباتي',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _mode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _logged = false;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), _check);
  }

  Future<void> _check() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _logged = p.getBool('logged_in') ?? false;
      _loading = false;
    });
    if (_logged) {
      final l = await LockService.isLocked();
      if (mounted) setState(() => _locked = l);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SplashScreen();
    if (!_logged) return const LoginScreen();
    if (_locked) return LockScreen(onUnlocked: () => setState(() => _locked = false));
    return const MainShell();
  }
}
