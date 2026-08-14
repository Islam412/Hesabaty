import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/settings_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneFull;
  final VoidCallback onRegistered;
  const OtpScreen({super.key, required this.phoneFull, required this.onRegistered});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';
  int _seconds = 59;
  Timer? _timer;
  bool _error = false;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _send());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_seconds <= 1) { t.cancel(); setState(() => _seconds = 0); } else { setState(() => _seconds--); }
    });
  }

  Future<void> _send() async {
    if (!mounted) return;
    setState(() { _code = (100000 + Random().nextInt(900000)).toString(); _error = false; _ctrl.clear(); });
    final l10n = AppLocalizations.of(context)!;
    final url = Uri.parse('https://wa.me/${widget.phoneFull}?text=${Uri.encodeComponent('${l10n.otpMessage} $_code')}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _verify() {
    final l10n = AppLocalizations.of(context)!;
    final entered = _ctrl.text.replaceAll(RegExp('[^0-9]'), '');
    if (entered == _code) {
      SettingsService.setRegistered(widget.phoneFull);
      Navigator.of(context).pop();
      widget.onRegistered();
    } else {
      setState(() => _error = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l10n.wrongCode),
          backgroundColor: AppTheme.expenseRed,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(l10n.enterOtp, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 30),
            Text(l10n.otpSentTo, style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🟢', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text('+${widget.phoneFull}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                InkWell(onTap: () => Navigator.pop(context), child: Text(l10n.changeNumber, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14, decoration: TextDecoration.underline))),
              ],
            ),
            const SizedBox(height: 40),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _error ? AppTheme.expenseRed : AppTheme.primaryBlue, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 14),
                  decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                  onChanged: (v) => setState(() => _error = false),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _seconds > 0
                ? Text('${l10n.resendWait} $_seconds ${l10n.resendSeconds}', style: TextStyle(color: Colors.grey.shade500))
                : InkWell(onTap: () { _send(); _startTimer(); }, child: Text(l10n.resendNow, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16, decoration: TextDecoration.underline))),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                onPressed: _verify,
                child: Text(l10n.continueBtn, style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
