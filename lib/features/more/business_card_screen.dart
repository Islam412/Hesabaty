import 'dart:io';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../core/services/business_card_image_service.dart';
import '../../core/services/share_service.dart';

class BusinessCardScreen extends StatefulWidget {
  const BusinessCardScreen({super.key});
  @override
  State<BusinessCardScreen> createState() => _BusinessCardScreenState();
}

class _BusinessCardScreenState extends State<BusinessCardScreen> {
  final _biz = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _activity = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _biz.text = prefs.getString('bc_biz') ?? '';
    _owner.text = prefs.getString('bc_owner') ?? '';
    _phone.text = prefs.getString('bc_phone') ?? '';
    _address.text = prefs.getString('bc_address') ?? '';
    _activity.text = prefs.getString('bc_activity') ?? '';
    for (final c in [_biz, _owner, _phone, _address, _activity]) {
      c.addListener(() => setState(() {}));
    }
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bc_biz', _biz.text.trim());
    await prefs.setString('bc_owner', _owner.text.trim());
    await prefs.setString('bc_phone', _phone.text.trim());
    await prefs.setString('bc_address', _address.text.trim());
    await prefs.setString('bc_activity', _activity.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardSaved), backgroundColor: AppTheme.incomeGreen));
  }

  Future<void> _shareImage() async {
    final path = await BusinessCardImageService.generate(
      businessName: _biz.text.trim(),
      ownerName: _owner.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      activity: _activity.text.trim(),
    );
    if (!mounted) return;
    await ShareService.shareReceiptImage(context, path, '🪪 ${_biz.text.trim()}\n${_owner.text.trim()}\n📞 ${_phone.text.trim()}');
  }

  Future<void> _shareVcard() async {
    final vcf = 'BEGIN:VCARD\nVERSION:3.0\nFN:${_owner.text.trim()}\nORG:${_biz.text.trim()}\nTEL;TYPE=CELL:${_phone.text.trim()}\nADR:;;${_address.text.trim()};;;\nNOTE:${_activity.text.trim()}\nEND:VCARD';
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/business_card.vcf');
    await f.writeAsString(vcf);
    if (!mounted) return;
    await ShareService.shareReceiptImage(context, f.path, '🪪 بطاقة عمل: ${_biz.text.trim()}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessCard)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_biz.text.isEmpty ? l10n.businessName : _biz.text, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_owner.text.isEmpty ? l10n.ownerName : _owner.text, style: const TextStyle(color: Color(0xFFDCE9FF), fontSize: 17, fontWeight: FontWeight.w600)),
                if (_activity.text.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('💼 ${_activity.text}', style: const TextStyle(color: Color(0xFFBBD4F7), fontSize: 14)),
                ],
                const SizedBox(height: 14),
                const Divider(color: Color(0x66FFFFFF), height: 8),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_phone.text.isEmpty ? '📞 ---' : '📞 ${_phone.text}', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (_address.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('📍 ${_address.text}', style: const TextStyle(color: Color(0xFFDCE9FF), fontSize: 13), textDirection: TextDirection.rtl),
                ],
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text('حساباتي', style: TextStyle(color: Color(0xFFBBD4F7), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(controller: _biz, decoration: InputDecoration(labelText: l10n.businessName, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _owner, decoration: InputDecoration(labelText: l10n.ownerName, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l10n.phoneNumber, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _address, decoration: InputDecoration(labelText: l10n.address, border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _activity, decoration: InputDecoration(labelText: l10n.activity, border: const OutlineInputBorder(), hintText: 'بقالة / ملابس / أدوات منزلية...')),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _save,
            child: Text(l10n.save, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _shareImage,
                  icon: const Icon(Icons.image),
                  label: Text(l10n.shareAsImage),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: _shareVcard,
                  icon: const Icon(Icons.contact_page),
                  label: Text(l10n.shareAsVcard),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
