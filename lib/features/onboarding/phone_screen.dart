import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  const PhoneScreen({super.key, required this.onRegistered});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _phone = TextEditingController();

  void _continue() {
    final digits = _phone.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length < 10) return;
    final full = digits.startsWith('20') ? digits : (digits.startsWith('0') ? '2$digits' : '20$digits');
    Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phoneFull: full, onRegistered: widget.onRegistered)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(l10n.enterPhone, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: l10n.phoneNumber,
                        border: InputBorder.none,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('+20', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Text('🇪', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(l10n.phoneDesc, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.8)),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                onPressed: _continue,
                child: Text(l10n.continueBtn, style: const TextStyle(fontSize: 18)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Text(l10n.termsText, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.privacyPolicy, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, decoration: TextDecoration.underline)),
                      Text(' - ', style: TextStyle(color: Colors.grey.shade400)),
                      Text(l10n.termsOfUse, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, decoration: TextDecoration.underline)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
