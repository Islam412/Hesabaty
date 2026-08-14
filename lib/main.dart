import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/theme.dart';
import 'core/services/auto_backup_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Cur.load();
  await NotificationService.init();
  Future.microtask(() async {
    try {
      await AutoBackupService.checkAndRunIfNeeded();
    } catch (_) {}
  });
  runApp(const MyApp());
}
