import 'package:flutter/material.dart';
import 'core/services/account_service.dart';
import 'data/services/realm_service.dart';
import 'app/app.dart';
import 'app/theme.dart';
import 'core/services/auto_backup_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  AccountService.onAccountChange(() async {
    try { await RealmService.reset(); } catch (_) {}
  });

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
