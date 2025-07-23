// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق طبي';

  @override
  String get welcome => 'مرحبا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get registerToGetStarted => 'سجل للبدء';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get next => 'التالي';

  @override
  String get chooseRole => 'اختر دورك:';

  @override
  String get selectDob => 'حدد تاريخ ميلادك:';

  @override
  String get finishRegistration => 'إنهاء التسجيل';

  @override
  String get doctor => 'طبيب';

  @override
  String get patient => 'مريض';

  @override
  String get pickDate => 'اختر التاريخ';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح!';

  @override
  String get registrationFailed => 'فشل التسجيل.';

  @override
  String error(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get pleaseFillAllFields => 'يرجى ملء جميع الحقول.';

  @override
  String get enterValidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get passwordMustBe6 => 'يجب أن تكون كلمة المرور أكثر من 6 أحرف';

  @override
  String get today => 'اليوم:';

  @override
  String get yourRole => 'دورك:';

  @override
  String get welcomeDescription => 'شكرًا لانضمامك! سجل الدخول أو أنشئ حسابًا جديدًا للبدء!';
}
