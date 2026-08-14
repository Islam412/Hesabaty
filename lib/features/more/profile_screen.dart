import 'package:flutter/material.dart';
import '../../core/services/flash_service.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/account_service.dart';
import '../../data/services/realm_service.dart';
import '../../app/theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _owner = '';
  String _phone = '';
  String _address = '';
  String _currency = Cur.v;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _name = p.getString('profile_name') ?? 'حساباتي';
      _owner = p.getString('profile_owner') ?? '';
      _phone = p.getString('profile_phone') ?? p.getString('user_phone') ?? '';
      _address = p.getString('profile_address') ?? '';
      _currency = p.getString('profile_currency') ?? Cur.v;
    });
  }

  Future<void> _edit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController(text: _name);
    final owner = TextEditingController(text: _owner);
    final phone = TextEditingController(text: _phone);
    final address = TextEditingController(text: _address);
    final currency = TextEditingController(text: _currency);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: InputDecoration(labelText: l10n.businessName, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: owner, decoration: InputDecoration(labelText: l10n.ownerName, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l10n.enterPhone, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: address, decoration: InputDecoration(labelText: l10n.address, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: currency, decoration: InputDecoration(labelText: l10n.currency, border: const OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.setString('profile_name', name.text.trim());
              await p.setString('profile_owner', owner.text.trim());
              await p.setString('profile_phone', phone.text.trim());
              await p.setString('profile_address', address.text.trim());
              await p.setString('profile_currency', currency.text.trim());
              final sess = await AccountService.sessionPhone();
              if (sess != null) await AccountService.update(sess, {'name': name.text.trim(), 'owner': owner.text.trim(), 'address': address.text.trim(), 'currency': currency.text.trim()});
              if (sess != null) await AccountService.update(sess, {'name': name.text.trim(), 'owner': owner.text.trim(), 'address': address.text.trim(), 'currency': currency.text.trim()});
              if (ctx.mounted) Navigator.pop(ctx);
              await _load();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileSaved), backgroundColor: AppTheme.incomeGreen));
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.expenseRed), onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.logout)),
        ],
      ),
    );
    if (ok != true) return;
    final p = await SharedPreferences.getInstance();
    await AccountService.logout();
    RealmService.reset();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initial = _name.isNotEmpty ? _name[0] : '؟';
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: _edit)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8), const Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(_name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                if (_owner.isNotEmpty) Text(_owner, style: const TextStyle(color: Color(0xFFDCE9FF), fontSize: 14)),
                const SizedBox(height: 10),
                if (_phone.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), borderRadius: BorderRadius.circular(12)),
                    child: Text(_phone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), textDirection: TextDirection.ltr),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_address.isNotEmpty) _infoRow(Icons.location_on, l10n.address, _address),
          _infoRow(Icons.currency_exchange, l10n.currency, _currency),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _edit,
            icon: const Icon(Icons.edit),
            label: Text(l10n.editProfile, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.expenseRed, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.12), child: Icon(icon, color: AppTheme.primaryBlue, size: 22)),
        title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
