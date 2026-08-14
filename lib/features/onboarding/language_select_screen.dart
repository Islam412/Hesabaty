import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class LanguageSelectScreen extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const LanguageSelectScreen({super.key, required this.onSelected});

  Widget _langButton(BuildContext context, String label, {String? code}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (code == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
          } else {
            onSelected(code);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 26),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _langButton(context, 'Turkish'),
              _langButton(context, 'English', code: 'en'),
              _langButton(context, 'Français'),
              _langButton(context, 'العربية', code: 'ar'),
              _langButton(context, 'مصري'),
            ],
          ),
        ),
      ),
    );
  }
}
