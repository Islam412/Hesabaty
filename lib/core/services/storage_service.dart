import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kBase = 'storage_base_path';

  static Future<String> basePath() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString(_kBase);
    if (saved != null && saved.isNotEmpty) return saved;
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<String> defaultPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<bool> isCustom() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString(_kBase) ?? '').isNotEmpty;
  }

  static Future<void> setBasePath(String path) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBase, path);
  }

  static Future<Map<String, dynamic>> stats() async {
    final base = await basePath();
    double db = 0, backups = 0;
    int dbFiles = 0, backupFiles = 0;
    try {
      final d = Directory(base);
      if (await d.exists()) {
        await for (final e in d.list()) {
          final name = e.path.split('/').last;
          if (e is File && name.endsWith('.realm')) {
            db += (await e.stat()).size;
            dbFiles++;
          }
        }
      }
      final b = Directory('$base/HesabatyBackups');
      if (await b.exists()) {
        await for (final e in b.list(recursive: true)) {
          if (e is File) {
            backups += (await e.stat()).size;
            backupFiles++;
          }
        }
      }
    } catch (_) {}
    return {'db': db, 'backups': backups, 'dbFiles': dbFiles, 'backupFiles': backupFiles, 'total': db + backups};
  }

  static String fmt(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} بايت';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  static Future<void> migrate(String newPath) async {
    final old = await basePath();
    if (old == newPath) return;
    final newDir = Directory(newPath);
    if (!await newDir.exists()) await newDir.create(recursive: true);
    final oldDir = Directory(old);
    if (await oldDir.exists()) {
      await for (final e in oldDir.list()) {
        final name = e.path.split('/').last;
        if (e is File && name.endsWith('.realm')) {
          try { await e.copy('$newPath/$name'); } catch (_) {}
        }
        if (e is Directory && name.endsWith('.management')) {
          try { await _copyDir(e, '$newPath/$name'); } catch (_) {}
        }
      }
    }
    final ob = Directory('$old/HesabatyBackups');
    if (await ob.exists()) {
      try { await _copyDir(ob, '$newPath/HesabatyBackups'); } catch (_) {}
    }
    await setBasePath(newPath);
  }

  static Future<void> _copyDir(Directory src, String dst) async {
    final d = Directory(dst);
    if (!await d.exists()) await d.create(recursive: true);
    await for (final e in src.list()) {
      final name = e.path.split('/').last;
      if (e is File) {
        try { await e.copy('$dst/$name'); } catch (_) {}
      }
    }
  }
}
