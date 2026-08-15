import 'dart:io';
import 'storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareText(BuildContext context, String text) async {
    if (Platform.isLinux) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم مشاركة الإيصال كصورة 🖼️')),
        );
      }
      return;
    }
    try {
      await Share.share(text);
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  static Future<void> shareReceiptImage(BuildContext context, String imagePath, String text) async {
    if (Platform.isLinux) {
      final dir = Directory(await StorageService.basePath());
      final dest = File('${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png');
      await File(imagePath).copy(dest.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ صورة الإيصال في:\n${dest.path}')),
        );
      }
      return;
    }
    try {
      await Share.shareXFiles([XFile(imagePath)], text: text);
    } catch (_) {
      await shareText(context, text);
    }
  }
}
