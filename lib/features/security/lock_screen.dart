import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import 'lock_service.dart';
import 'pattern_lock.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});
  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  LockType _type = LockType.none;
  bool _biometric = false;
  bool _loading = true;
  String _pin = '';
  final _passwordCtrl = TextEditingController();
  bool _error = false;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _type = await LockService.getType();
    _biometric = await LockService.getBiometricEnabled();
    if (mounted) setState(() => _loading = false);
    if (_biometric && await LockService.isBiometricAvailable()) {
      await _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    final ok = await LockService.authenticateBiometric();
    if (ok) {
      widget.onUnlocked();
    }
  }

  Future<void> _verifyPin() async {
    if (await LockService.verifyPin(_pin)) {
      widget.onUnlocked();
    } else {
      setState(() { _error = true; _msg = 'الـ PIN غير صحيح'; });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() { _error = false; _msg = ''; _pin = ''; });
    }
  }

  Future<void> _verifyPassword() async {
    if (await LockService.verifyPassword(_passwordCtrl.text)) {
      widget.onUnlocked();
    } else {
      setState(() { _error = true; _msg = 'كلمة السر غير صحيحة'; });
      _passwordCtrl.clear();
    }
  }

  Future<void> _verifyPattern(List<int> pts) async {
    if (await LockService.verifyPattern(pts)) {
      widget.onUnlocked();
    } else {
      setState(() { _error = true; _msg = 'النقش غير صحيح'; });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() { _error = false; _msg = ''; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.lock, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 20),
                  const Text('التطبيق مقفل 🔒', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(_titleFor(_type), style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: _type == LockType.pin
                        ? _buildPin()
                        : _type == LockType.password
                            ? _buildPassword()
                            : _type == LockType.pattern
                                ? _buildPattern()
                                : const SizedBox.shrink(),
                  ),
                  if (_msg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                  if (_biometric) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54)),
                      onPressed: _tryBiometric,
                      icon: const Icon(Icons.fingerprint, size: 28),
                      label: const Text('فتح بالبصمة / الوجه', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleFor(LockType t) {
    switch (t) {
      case LockType.pin: return 'ادخل الـ PIN';
      case LockType.password: return 'ادخل كلمة السر';
      case LockType.pattern: return 'ارسم النقش';
      default: return '';
    }
  }

  Widget _buildPin() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: _error ? AppTheme.expenseRed : Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Text(_pin.isEmpty ? '••••' : _pin, style: TextStyle(fontSize: 28, letterSpacing: 10, color: _error ? AppTheme.expenseRed : Colors.black, fontWeight: FontWeight.bold), textDirection: TextDirection.ltr),
        ),
        const SizedBox(height: 20),
        ...List.generate(3, (row) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (col) {
            final n = row * 3 + col + 1;
            return Padding(
              padding: const EdgeInsets.all(6),
              child: _keyBtn('$n', () { if (_pin.length < 6) setState(() => _pin += '$n'); }),
            );
          }),
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: const EdgeInsets.all(6), child: _keyBtn('0', () { if (_pin.length < 6) setState(() => _pin += '0'); })),
            Padding(padding: const EdgeInsets.all(6), child: _keyBtn('⌫', () { if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1)); }, filled: false)),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: AppTheme.primaryBlue),
          onPressed: _verifyPin,
          child: const Text('فتح', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      children: [
        TextField(
          controller: _passwordCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'كلمة السر',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _error ? 'غير صحيحة' : null,
          ),
          onSubmitted: (_) => _verifyPassword(),
        ),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
          onPressed: _verifyPassword,
          child: const Text('فتح', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPattern() {
    return PatternLock(
      color: _error ? AppTheme.expenseRed : AppTheme.primaryBlue,
      onCompleted: _verifyPattern,
    );
  }

  Widget _keyBtn(String label, VoidCallback onTap, {bool filled = true}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            color: filled ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: filled ? AppTheme.primaryBlue : Colors.grey))),
        ),
      ),
    );
  }
}
