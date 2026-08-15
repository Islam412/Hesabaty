import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/account_service.dart';
import '../../app/theme.dart';
import '../../core/services/business_card_image_service.dart';
import '../../core/services/image_picker_service.dart';
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
  final PageController _page = PageController();
  int _index = 0;
  String? _customBg;
  bool _loaded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
    final prefs = await AccPrefs.scoped();
    _biz.text = prefs.getString('bc_biz') ?? '';
    _owner.text = prefs.getString('bc_owner') ?? '';
    _phone.text = prefs.getString('bc_phone') ?? '';
    _address.text = prefs.getString('bc_address') ?? '';
    _activity.text = prefs.getString('bc_activity') ?? '';
    _customBg = prefs.getString('bc_custom_bg');
    for (final c in [_biz, _owner, _phone, _address, _activity]) {
      c.addListener(() => setState(() {}));
    }
    setState(() => _loaded = true);
    } catch (e) {
      debugPrint('⚠️ business card load error: $e');
      setState(() => _loaded = true);
    }
  }

  List<CardTemplate> get _templates => [
        const CardTemplate(id: 'gold', name: 'ذهبي فاخر', bg: [Color(0xFF141414), Color(0xFF242424)], text: Color(0xFFE5A83B), sub: Color(0xFFD8B56A), accent: Color(0xFFE5A83B), pattern: 'mandala'),
        const CardTemplate(id: 'blue', name: 'أزرق احترافي', bg: [Color(0xFF2E7CF6), Color(0xFF1E5BB8)], text: Colors.white, sub: Color(0xFFDCE9FF), accent: Color(0xFFBBD4F7), pattern: 'lattice'),
        const CardTemplate(id: 'teal', name: 'تركوازي', bg: [Color(0xFF00695C), Color(0xFF004D40)], text: Colors.white, sub: Color(0xFFB2DFDB), accent: Color(0xFF80CBC4), pattern: 'stars'),
        const CardTemplate(id: 'light', name: 'فاتح أنيق', bg: [Color(0xFFF5F7FA), Color(0xFFE3EBF5)], text: Color(0xFF1F3B5C), sub: Color(0xFF5A7590), accent: Color(0xFF2E7CF6), pattern: 'lattice'),
        const CardTemplate(id: 'purple', name: 'بنفسجي', bg: [Color(0xFF4A148C), Color(0xFF311B92)], text: Colors.white, sub: Color(0xFFE1BEE7), accent: Color(0xFFCE93D8), pattern: 'mandala'),
        const CardTemplate(id: 'red', name: 'أحمر ملكي', bg: [Color(0xFFB71C1C), Color(0xFF7F0000)], text: Colors.white, sub: Color(0xFFFFCDD2), accent: Color(0xFFFF8A80), pattern: 'stars'),
        CardTemplate(id: 'custom', name: AppLocalizations.of(context)!.customDesign, bg: const [Color(0xFF000000), Color(0xFF111111)], text: Colors.white, sub: Colors.white70, accent: Colors.white, customImage: _customBg),
      ];

  Future<void> _pickCustomBg() async {
    final path = await ImagePickerService.pickAndSave(fromCamera: false);
    if (path == null) return;
    final prefs = await AccPrefs.scoped();
    await prefs.setString('bc_custom_bg', path);
    setState(() {
      _customBg = path;
      _index = _templates.length - 1;
      _page.jumpToPage(_index);
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await AccPrefs.scoped();
    await prefs.setString('bc_biz', _biz.text.trim());
    await prefs.setString('bc_owner', _owner.text.trim());
    await prefs.setString('bc_phone', _phone.text.trim());
    await prefs.setString('bc_address', _address.text.trim());
    await prefs.setString('bc_activity', _activity.text.trim());
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardSaved), backgroundColor: AppTheme.incomeGreen));
  }

  Future<String> _generate() {
    final t = _templates[_index];
    return BusinessCardImageService.generate(
      t: t,
      businessName: _biz.text.trim(),
      ownerName: _owner.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      activity: _activity.text.trim(),
    );
  }

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    final tmp = await _generate();
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/business_card.png');
    await File(tmp).copy(dest.path);
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.cardDownloaded}\n${dest.path}'), backgroundColor: AppTheme.incomeGreen));
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    final path = await _generate();
    setState(() => _busy = false);
    if (!mounted) return;
    await ShareService.shareReceiptImage(context, path, '🪪 ${_biz.text.trim()}\n${_owner.text.trim()}\n📞 ${_phone.text.trim()}');
  }

  Widget _preview(CardTemplate t) {
    final isCustomEmpty = t.id == 'custom' && t.customImage == null;
    return GestureDetector(
      onTap: isCustomEmpty ? _pickCustomBg : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: t.id == 'custom' ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.5), width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (t.customImage != null && File(t.customImage!).existsSync())
                Image.file(File(t.customImage!), fit: BoxFit.cover, color: const Color(0x99000000), colorBlendMode: BlendMode.darken),
              if (!isCustomEmpty) CustomPaint(painter: CardPatternPainter(pattern: t.pattern, color: t.accent.withOpacity(0.16))),
              if (isCustomEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate, color: t.accent, size: 44),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.pickBackground, style: TextStyle(color: t.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_biz.text.isEmpty ? '—' : _biz.text, style: TextStyle(color: t.text, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_owner.text.isEmpty ? '—' : _owner.text, style: TextStyle(color: t.sub, fontSize: 15, fontWeight: FontWeight.w600)),
                      if (_activity.text.isNotEmpty) Text('💼 ${_activity.text}', style: TextStyle(color: t.sub, fontSize: 12)),
                      const SizedBox(height: 10),
                      Divider(color: t.accent.withOpacity(0.8), thickness: 1.5, indent: 40, endIndent: 40),
                      const SizedBox(height: 8),
                      Text('📞 ${_phone.text.isEmpty ? '—' : _phone.text}', style: TextStyle(color: t.text, fontSize: 16, fontWeight: FontWeight.bold)),
                      if (_address.text.isNotEmpty) Text('📍 ${_address.text}', style: TextStyle(color: t.sub, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('حساباتي', style: TextStyle(color: t.sub, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editSheet() async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.editCard, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: _biz, decoration: InputDecoration(labelText: l10n.businessName, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _owner, decoration: InputDecoration(labelText: l10n.ownerName, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: InputDecoration(labelText: l10n.phoneNumber, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _address, decoration: InputDecoration(labelText: l10n.address, border: const OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _activity, decoration: InputDecoration(labelText: l10n.activity, border: const OutlineInputBorder())),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _pickCustomBg();
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(l10n.pickBackground),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 50)),
                onPressed: _save,
                child: Text(l10n.save),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final templates = _templates;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.businessCard)),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _page,
              itemCount: templates.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (ctx, i) => _preview(templates[i]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(templates.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 12 : 9,
                  height: i == _index ? 12 : 9,
                  decoration: BoxDecoration(
                    color: i == _index ? AppTheme.primaryBlue : AppTheme.primaryBlue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                )),
          ),
          const SizedBox(height: 4),
          Text(templates[_index].name, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(l10n.chooseTemplate, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _editSheet,
            icon: const Icon(Icons.edit, size: 18),
            label: Text(l10n.editCard),
          ),
          const Spacer(),
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.incomeGreen.withOpacity(0.85), padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _busy ? null : _send,
                      child: Text(l10n.sendCard, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _busy ? null : _download,
                      child: Text(l10n.download, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
