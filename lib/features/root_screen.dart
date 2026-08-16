import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app.dart';
import '../core/services/settings_service.dart';
import 'main_shell.dart';
import 'onboarding/language_select_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding/phone_screen.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key});
  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  String? _stage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final locale = await SettingsService.getLocale();
    final registered = await SettingsService.isRegistered();
    final onboarded = await SettingsService.isOnboarded();
    if (!mounted) return;
    setState(() {
      if (locale == null) {
        _stage = 'language';
      } else if (!registered) {
        _stage = 'phone';
      } else if (!onboarded) {
        _stage = 'onboarding';
      } else {
        _stage = 'main';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_stage == 'language') {
      return LanguageSelectScreen(
        onSelected: (code) {
          ref.read(localeProvider.notifier).state = Locale(code);
          SettingsService.saveLocale(code);
          setState(() => _stage = 'phone');
        },
      );
    }
    if (_stage == 'phone') {
      return PhoneScreen(onRegistered: () => setState(() => _stage = 'onboarding'));
    }
    if (_stage == 'onboarding') {
      return OnboardingScreen(
        onFinished: () {
          SettingsService.setOnboarded();
          setState(() => _stage = 'main');
        },
      );
    }
    return const MainShell();
  }
}
