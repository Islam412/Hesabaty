import 'dart:io';
import '../../core/services/storage_service.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';

class ImageExportScreen extends StatefulWidget {
  final Widget child;
  final String fileName;
  const ImageExportScreen({super.key, required this.child, this.fileName = 'hesabaty'});
  @override
  State<ImageExportScreen> createState() => _ImageExportScreenState();
}

class _ImageExportScreenState extends State<ImageExportScreen> {
  final GlobalKey _bk = GlobalKey();
  bool _busy = false;

  Future<File> _capture() async {
    final boundary = _bk.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final ByteData? bd = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = bd!.buffer.asUint8List();
    final dir = Directory(await StorageService.basePath());
    final f = File('${dir.path}/${widget.fileName}_${DateTime.now().millisecondsSinceEpoch}.png');
    await f.writeAsBytes(bytes);
    return f;
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final f = await _capture();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('💾 تم حفظ الصورة:\n${f.path}'), backgroundColor: AppTheme.incomeGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e'), backgroundColor: AppTheme.expenseRed));
    }
    setState(() => _busy = false);
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final f = await _capture();
      try {
        await Share.shareXFiles([XFile(f.path)], subject: 'حساباتي');
      } catch (_) {
        await Share.share('🖼️ صورة إيصال — حساباتي:\n${f.path}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل المشاركة: $e'), backgroundColor: AppTheme.expenseRed));
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تصدير كصورة 🖼️')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: RepaintBoundary(key: _bk, child: widget.child),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('حفظ الصورة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.incomeGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة الصورة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
