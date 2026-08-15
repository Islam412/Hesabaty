import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/services/storage_service.dart';
import '../../data/services/realm_service.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({super.key});
  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  String _path = '';
  bool _custom = false;
  Map<String, dynamic> _stats = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final path = await StorageService.basePath();
    final custom = await StorageService.isCustom();
    final stats = await StorageService.stats();
    if (!mounted) return;
    setState(() {
      _path = path;
      _custom = custom;
      _stats = stats;
    });
  }

  Future<void> _change() async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير مكان التخزين'),
        content: Text('هننقل كل البيانات (قواعد البيانات + النسخ الاحتياطية) إلى:\n\n$dir'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('نقل')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      RealmService.reset();
      await StorageService.migrate(dir);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نقل التخزين بنجاح'), backgroundColor: AppTheme.incomeGreen));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل النقل: $e'), backgroundColor: AppTheme.expenseRed));
    }
    setState(() => _busy = false);
  }

  Future<void> _resetDefault() async {
    final def = await StorageService.defaultPath();
    if (def == _path) return;
    setState(() => _busy = true);
    RealmService.reset();
    await StorageService.migrate(def);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ رجعنا للمكان الافتراضي'), backgroundColor: AppTheme.incomeGreen));
    await _load();
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التخزين')),
      body: _busy
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('جارٍ نقل البيانات...')]))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00BCD4), Color(0xFF0097A7)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.storage, color: Colors.white, size: 48),
                      const SizedBox(height: 10),
                      Text(StorageService.fmt((_stats['total'] as double?) ?? 0), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                      const Text('إجمالي المساحة المستخدمة', style: TextStyle(color: Color(0xFFE0F7FA), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: Text(_custom ? '📁 مكان مخصص' : '🏠 المكان الافتراضي', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statCard('قواعد البيانات', StorageService.fmt((_stats['db'] as double?) ?? 0), '${_stats['dbFiles'] ?? 0} ملف', AppTheme.primaryBlue, Icons.dns),
                    const SizedBox(width: 10),
                    _statCard('النسخ الاحتياطية', StorageService.fmt((_stats['backups'] as double?) ?? 0), '${_stats['backupFiles'] ?? 0} ملف', const Color(0xFFE5A83B), Icons.backup),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('مكان التخزين الحالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(_path, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), textDirection: TextDirection.ltr),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00BCD4), padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _change,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('تغيير مكان التخزين', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => launchUrl(Uri.parse('file://$_path'), mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.launch),
                  label: const Text('فتح المجلد في مدير الملفات'),
                ),
                if (_custom) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _resetDefault,
                    icon: const Icon(Icons.settings_backup_restore, color: AppTheme.expenseRed),
                    label: const Text('الرجوع للمكان الافتراضي', style: TextStyle(color: AppTheme.expenseRed)),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _statCard(String label, String value, String sub, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            Text(sub, style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
