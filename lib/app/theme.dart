import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2E7CF6);
  static const Color primaryDark = Color(0xFF1E5BB8);
  static const Color accentPurple = Color(0xFF5E35B1);
  static const Color incomeGreen = Color(0xFF16A34A);
  static const Color expenseRed = Color(0xFFDC2626);
  static const Color gold = Color(0xFFE5A83B);
  static const Color bgLight = Color(0xFFF5F7FA);
  static const Color bgDark = Color(0xFF0F1626);
  static const Color cardDark = Color(0xFF1B2437);
  static const String fontFamily = 'Almarai';

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.light),
        scaffoldBackgroundColor: bgLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Color(0xFF16324F), fontSize: 20, fontWeight: FontWeight.w800, fontFamily: fontFamily),
          iconTheme: IconThemeData(color: Color(0xFF16324F)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: BorderSide(color: primaryBlue.withOpacity(0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE3EBF5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE3EBF5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryBlue, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: primaryBlue.withOpacity(0.15),
          backgroundColor: Colors.white,
          elevation: 8,
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(fontSize: 12, fontWeight: states.contains(MaterialState.selected) ? FontWeight.w800 : FontWeight.w500, fontFamily: fontFamily),
          ),
        ),
        snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        bottomSheetTheme: const BottomSheetThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 4),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue, brightness: Brightness.dark, surface: bgDark),
        scaffoldBackgroundColor: bgDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: fontFamily),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2A3650))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2A3650))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: primaryBlue, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: primaryBlue.withOpacity(0.25),
          backgroundColor: cardDark,
          elevation: 8,
          labelTextStyle: MaterialStateProperty.resolveWith(
            (states) => TextStyle(fontSize: 12, fontWeight: states.contains(MaterialState.selected) ? FontWeight.w800 : FontWeight.w500, fontFamily: fontFamily),
          ),
        ),
        snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        bottomSheetTheme: const BottomSheetThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 4),
      );
}

class ThemeNotifier {
  static VoidCallback? listener;
  static Future<bool> isDark() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('theme_dark') ?? false;
  }
  static Future<void> toggle() async {
    final p = await SharedPreferences.getInstance();
    final dark = p.getBool('theme_dark') ?? false;
    await p.setBool('theme_dark', !dark);
    listener?.call();
  }
}
