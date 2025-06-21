// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get detect => 'كشف';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get english => 'إنجليزية';

  @override
  String get turkish => 'التركية';

  @override
  String get arabic => 'العربية';

  @override
  String get liveHandDetection => 'كشف اليد المباشر';

  @override
  String get selectLanguage => 'إختر اللغة';

  @override
  String get apply => 'تطبيق';

  @override
  String get cancel => 'إلغاء';
}
