import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../features/root_screen.dart';
import 'theme.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

class DebtCashApp extends ConsumerWidget {
  const DebtCashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Debt & Cash App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootScreen(),
    );
  }
}
