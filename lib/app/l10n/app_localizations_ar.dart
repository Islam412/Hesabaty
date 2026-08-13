// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دفتر رأس المال والديون';

  @override
  String get more => 'المزيد';

  @override
  String get cashBook => 'دفتر النقدية';

  @override
  String get debtBook => 'دفتر الديون';

  @override
  String get income => 'إيراد';

  @override
  String get expense => 'مصروف';

  @override
  String get balance => 'الرصيد';

  @override
  String get customers => 'العملاء';

  @override
  String get suppliers => 'الموردون';
}
