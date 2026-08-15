import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/account_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/watcher_service.dart';
import '../../data/services/realm_service.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String _sentCode = '';

  String _wa(String phone) {
    var d = phone.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0')) d = '20' + d.substring(1);
    return d;
  }

  String _key(String phone) {
    var d = phone.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('20') && d.length > 11) d = '0' + d.substring(2);
    return d;
  }

  Future<void> _send() async {
    final key = _key(_phone.text);
    if (key.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب رقم الموبايل صح (11 رقم)'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    setState(() => _busy = true);
    _sentCode = (100000 + Random().nextInt(900000)).toString();
    final exists = await AccountService.exists(key);
    final acc = exists ? await AccountService.get(key) : null;
    final msg = '🔐 كود التحقق لتطبيق حساباتي:\n\n$_sentCode\n\n${exists ? 'مرحبًا بعودتك يا ${(acc?['name'] ?? '')} 👋' : 'هيتعمل حساب جديد للرقم ده بعد التحقق.'}\n\n⚠️ لا تشارك الكود مع أي شخص.';
    try {
      await launchUrl(Uri.parse('https://wa.me/${_wa(_phone.text)}?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
    } catch (_) {}
    setState(() {
      _codeSent = true;
      _busy = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('📲 افتح واتساب — الكود في رسالة على الرقم اللي كتبته'),
      backgroundColor: AppTheme.incomeGreen,
      duration: const Duration(seconds: 6),
    ));
  }

  Future<Map<String, String>?> _showRegister() async {
    final name = TextEditingController();
    final owner = TextEditingController();
    final address = TextEditingController();
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 حساب جديد — كمّل بياناتك'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم النشاط التجاري *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: owner, decoration: const InputDecoration(labelText: 'اسم صاحب النشاط', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: address, decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              Navigator.pop(ctx, {'name': name.text.trim(), 'owner': owner.text.trim(), 'address': address.text.trim()});
            },
            child: const Text('إنشاء الحساب'),
          ),
        ],
      ),
    );
  }

  Future<void> _verify() async {
    if (_code.text.trim() != _sentCode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكود غير صحيح ❌'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    setState(() => _busy = true);
    final key = _key(_phone.text);
    try {
      if (await AccountService.exists(key)) {
        final acc = await AccountService.get(key);
        await AccountService.login(key);
        RealmService.reset();
        WatcherService.start();
        if (!mounted) return;
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('مرحبًا بعودتك 👋 حساب: ${acc?['name'] ?? ''}'), backgroundColor: AppTheme.incomeGreen));
      } else {
        final data = await _showRegister();
        if (data == null) {
          setState(() => _busy = false);
          return;
        }
        await AccountService.register(key, name: data['name']!, owner: data['owner'] ?? '', address: data['address'] ?? '');
        await AccountService.login(key);
        RealmService.reset();
        WatcherService.start();
        if (!mounted) return;
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ اتعمل حساب جديد لـ ${data['name']}'), backgroundColor: AppTheme.incomeGreen));
      }
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (r) => false);
    } catch (_) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text('حساباتي', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
              const SizedBox(height: 6),
              Center(child: Text('${l10n.welcome} — كل رقم ليه حسابه المستقل', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14))),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(labelText: 'رقم الموبايل', hintText: '01xxxxxxxxx', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 14),
                    if (_codeSent) ...[
                      TextField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          labelText: 'كود التحقق (6 أرقام)',
                          hintText: '------',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.key),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366), minimumSize: const Size(double.infinity, 54)),
                      onPressed: _busy ? null : (_codeSent ? _verify : _send),
                      icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(_codeSent ? Icons.verified_user : Icons.chat_bubble),
                      label: Text(_codeSent ? l10n.verifyCode : 'إرسال الكود على واتساب', style: const TextStyle(fontSize: 16)),
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _send,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text('إعادة الإرسال', style: TextStyle(color: AppTheme.primaryBlue)),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Text('🔒 الرقم المسجل بيفتح حسابه ببياناته — رقم جديد بيعمل حساب جديد', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
