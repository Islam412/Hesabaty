import os, json

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

for path, extra in [
    ('lib/l10n/app_en.arb', {"enterPhone":"Please enter your phone number","phoneDesc":"Your phone number lets you securely access your account from any phone, anywhere.","continueBtn":"Continue","enterOtp":"Please enter the secret code you received","otpSentTo":"A 6-digit code was sent to","changeNumber":"Change number","resendWait":"You can resend the code in","resendSeconds":"seconds","resendNow":"Resend code","termsText":"By tapping continue, you agree that you have read and accepted the","privacyPolicy":"Privacy Policy","termsOfUse":"Terms of Use","otpMessage":"Your verification code is:","wrongCode":"Incorrect code, please try again"}),
    ('lib/l10n/app_ar.arb', {"enterPhone":"المرجو إدخال رقم الهاتف","phoneDesc":"يسمح لك رقم الهاتف بالولوج بأمان إلى حسابك الخاص من أي هاتف ومن أي مكان.","continueBtn":"مواصلة","enterOtp":"المرجو إدخال الرمز السري الذي تلقيته","otpSentTo":"تم إرسال رمز مكون من 6 أرقام إلى","changeNumber":"تغيير الرقم","resendWait":"يمكنك إعادة إرسال الرمز بعد","resendSeconds":"ثانية","resendNow":"إعادة إرسال الرمز","termsText":"بالنقر على متابعة، فإنك تقر بأنك قد قرأت وقبلت","privacyPolicy":"سياسة الخصوصية","termsOfUse":"شروط الاستعمال","otpMessage":"رمز التأكيد الخاص بك هو:","wrongCode":"الرمز غير صحيح، حاول مرة أخرى"}),
]:
    d = json.load(open(path, encoding='utf-8'))
    d.update(extra)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, indent=2)

w('lib/core/services/settings_service.dart', """import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _localeKey = 'locale';
  static const _themeKey = 'themeMode';
  static const _onboardKey = 'onboarded';
  static const _registeredKey = 'registered';
  static const _phoneKey = 'user_phone';

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardKey, true);
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredKey) ?? false;
  }

  static Future<void> setRegistered(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registeredKey, true);
    await prefs.setString(_phoneKey, phone);
  }
}
""")

w('lib/features/onboarding/phone_screen.dart', """import 'package:flutter/material.dart';
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
""")

w('lib/features/onboarding/otp_screen.dart', """import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
    setState(() { _code = (100000 + Random().nextInt(900000)).toString(); });
    final l10n = AppLocalizations.of(context)!;
    final url = Uri.parse('https://wa.me/${widget.phoneFull}?text=${Uri.encodeComponent('${l10n.otpMessage} $_code')}');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _verify() {
    final l10n = AppLocalizations.of(context)!;
    if (_ctrl.text == _code) {
      SettingsService.setRegistered(widget.phoneFull);
      widget.onRegistered();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.wrongCode)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = _ctrl.text;
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
            SizedBox(
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _ctrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(color: Colors.transparent),
                    caretColor: Colors.transparent,
                    decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 52,
                        height: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryBlue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text(i < text.length ? text[i] : '', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
""")

w('lib/features/root_screen.dart', """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/app.dart';
import '../core/services/settings_service.dart';
import 'main_shell.dart';
import 'onboarding/language_select_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding/phone_screen.dart';

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
""")

p = 'lib/features/cash_book/cash_book_screen.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("FloatingActionButton.extended(backgroundColor: AppTheme.incomeGreen, onPressed: () => _add('income')", "FloatingActionButton.extended(heroTag: 'cash_inc', backgroundColor: AppTheme.incomeGreen, onPressed: () => _add('income')")
s = s.replace("FloatingActionButton.extended(backgroundColor: AppTheme.expenseRed, onPressed: () => _add('expense')", "FloatingActionButton.extended(heroTag: 'cash_exp', backgroundColor: AppTheme.expenseRed, onPressed: () => _add('expense')")
open(p, 'w', encoding='utf-8').write(s)

p = 'lib/features/debt_book/contact_details_screen.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("FloatingActionButton.extended(backgroundColor: AppTheme.expenseRed, onPressed: () => _addTx('given')", "FloatingActionButton.extended(heroTag: 'det_given', backgroundColor: AppTheme.expenseRed, onPressed: () => _addTx('given')")
s = s.replace("FloatingActionButton.extended(backgroundColor: AppTheme.incomeGreen, onPressed: () => _addTx('taken')", "FloatingActionButton.extended(heroTag: 'det_taken', backgroundColor: AppTheme.incomeGreen, onPressed: () => _addTx('taken')")
open(p, 'w', encoding='utf-8').write(s)

p = 'lib/features/debt_book/debt_book_screen.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("floatingActionButton: FloatingActionButton.extended(\n        onPressed: () => _openAdd(!isCustomers),", "floatingActionButton: FloatingActionButton.extended(\n        heroTag: 'debt_add',\n        onPressed: () => _openAdd(!isCustomers),")
open(p, 'w', encoding='utf-8').write(s)

print("✅ Phone registration + WhatsApp OTP ready!")
