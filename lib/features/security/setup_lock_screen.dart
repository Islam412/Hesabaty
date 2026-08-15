import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import 'lock_service.dart';
import 'pattern_lock.dart';

class SetupLockScreen extends StatefulWidget {
  const SetupLockScreen({super.key});
  @override
  State<SetupLockScreen> createState() => _SetupLockScreenState();
}

class _SetupLockScreenState extends State<SetupLockScreen> {
  LockType _type = LockType.none;
  bool _biometric = false;
  bool _bioAvailable = false;
  List<BiometricType> _bioTypes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _type = await LockService.getType();
    _biometric = await LockService.getBiometricEnabled();
    _bioAvailable = await LockService.isBiometricAvailable();
    _bioTypes = await LockService.availableBiometrics();
    setState(() {});
  }

  Future<void> _chooseBiometric() async {
    if (!await LockService.isBiometricAvailable()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('البصمة غير متاحة على هذا الجهاز — جرّب على موبايل بيدعم بصمة'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    final types = await LockService.availableBiometrics();
    final label = types.contains(BiometricType.face) ? 'الوجه' : 'الإصبع';
    final ok = await LockService.authenticateBiometric();
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التحقق من بصمة $label'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    await LockService.setBiometric();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم تفعيل الفتح ببصمة $label'), backgroundColor: AppTheme.incomeGreen));
    _load();
  }

  Future<void> _choosePin() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    String? err;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          title: const Text('🔢 تعيين PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c1, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(labelText: 'PIN (4-6 أرقام)', border: const OutlineInputBorder(), counterText: '')),
              const SizedBox(height: 10),
              TextField(controller: c2, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(labelText: 'تأكيد PIN', border: const OutlineInputBorder(), counterText: '')),
              if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: AppTheme.expenseRed, fontSize: 12))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () {
              if (c1.text.length < 4) { setS(() => err = 'الـ PIN لازم يكون 4 أرقام على الأقل'); return; }
              if (c1.text != c2.text) { setS(() => err = 'الـ PIN مش متطابق'); return; }
              Navigator.pop(ctx, true);
            }, child: const Text('حفظ')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await LockService.setPin(c1.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ الـ PIN'), backgroundColor: AppTheme.incomeGreen));
      _load();
    }
  }

  Future<void> _choosePassword() async {
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    String? err;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          title: const Text('🔐 تعيين كلمة سر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: c1, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: c2, obscureText: true, decoration: const InputDecoration(labelText: 'تأكيد كلمة السر', border: OutlineInputBorder())),
              if (err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err!, style: const TextStyle(color: AppTheme.expenseRed, fontSize: 12))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            FilledButton(onPressed: () {
              if (c1.text.length < 4) { setS(() => err = 'كلمة السر قصيرة'); return; }
              if (c1.text != c2.text) { setS(() => err = 'كلمة السر مش متطابقة'); return; }
              Navigator.pop(ctx, true);
            }, child: const Text('حفظ')),
          ],
        ),
      ),
    );
    if (ok == true) {
      await LockService.setPassword(c1.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ كلمة السر'), backgroundColor: AppTheme.incomeGreen));
      _load();
    }
  }

  Future<void> _choosePattern() async {
    List<int>? saved;
    int step = 1;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          title: Text(step == 1 ? '✋ ارسم النقش' : '✋ ارسم النقش تاني للتأكيد'),
          content: SizedBox(
            width: 280,
            height: 280,
            child: PatternLock(
              onCompleted: (pts) {
                if (pts.length < 4) {
                  ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(content: Text('النقش لازم 4 نقاط على الأقل'), backgroundColor: AppTheme.expenseRed));
                  return;
                }
                if (step == 1) {
                  saved = pts;
                  setS(() => step = 2);
                } else {
                  if (saved != null && _listsEqual(saved!, pts)) {
                    Navigator.pop(ctx, true);
                  } else {
                    ScaffoldMessenger.of(ctx2).showSnackBar(const SnackBar(content: Text('النقش مش متطابق'), backgroundColor: AppTheme.expenseRed));
                    saved = null;
                    setS(() => step = 1);
                  }
                }
              },
            ),
          ),
          actions: [FilledButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء'))],
        ),
      ),
    );
    if (saved != null && step == 2) {
      // تم بنجاح من pop
    }
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قفل التطبيق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 42),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('حماية التطبيق', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('اختر طريقة الفتح المناسبة ليك', style: TextStyle(color: Color(0xFFFCE4EC), fontSize: 13)),
              ])),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('طريقة الفتح', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          _typeTile(LockType.biometric, 'بصمة الإصبع / الوجه', Icons.fingerprint, AppTheme.incomeGreen, onTap: _chooseBiometric, subtitle: _bioAvailable ? '✅ متاح على جهازك' : '❌ غير متاح على هذا الجهاز'),
          _typeTile(LockType.none, 'بدون قفل', Icons.lock_open, const Color(0xFF9E9E9E), onTap: () async { await LockService.disable(); _load(); }),
          _typeTile(LockType.pin, 'رقم PIN', Icons.dialpad, AppTheme.primaryBlue, onTap: _choosePin, subtitle: '4-6 أرقام'),
          _typeTile(LockType.password, 'كلمة سر', Icons.password, const Color(0xFF7C4DFF), onTap: _choosePassword),
          _typeTile(LockType.pattern, 'نقش', Icons.grid_3x3, const Color(0xFFE5A83B), onTap: _choosePattern),
          const SizedBox(height: 20),
          if (_bioAvailable) ...[
            const Text('المصادقة البيومترية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            Card(
              child: SwitchListTile(
                secondary: CircleAvatar(backgroundColor: AppTheme.incomeGreen.withOpacity(0.12), child: Icon(
                  _bioTypes.contains(BiometricType.face) ? Icons.face : Icons.fingerprint,
                  color: AppTheme.incomeGreen,
                )),
                title: Text(_bioTypes.contains(BiometricType.face) ? 'فتح بالوجه 👤' : 'فتح بالبصمة 👆', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('كإضافة للطريقة الأساسية'),
                value: _biometric,
                onChanged: (v) async {
                  if (v) {
                    final ok = await LockService.authenticateBiometric();
                    if (!ok) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل التحقق من البصمة'), backgroundColor: AppTheme.expenseRed)); return; }
                  }
                  await LockService.enableBiometric(v);
                  _load();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeTile(LockType t, String title, IconData icon, Color color, {required VoidCallback onTap, String? subtitle}) {
    final active = _type == t;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: active ? color.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: active ? color : Colors.transparent, width: 2)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: active ? const Icon(Icons.check_circle, color: AppTheme.incomeGreen) : const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
