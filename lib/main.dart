import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/services/realm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RealmService.realm;
  runApp(const MyApp());
}
