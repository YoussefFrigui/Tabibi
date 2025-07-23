// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Medical App';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerToGetStarted => 'Register to get started';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get next => 'Next';

  @override
  String get chooseRole => 'Choose your role:';

  @override
  String get selectDob => 'Select your date of birth:';

  @override
  String get finishRegistration => 'Finish Registration';

  @override
  String get doctor => 'Doctor';

  @override
  String get patient => 'Patient';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get accountCreated => 'Account created successfully!';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get pleaseFillAllFields => 'Please fill all fields.';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get passwordMustBe6 => 'Password must be > 6 chars';

  @override
  String get today => 'Today:';

  @override
  String get yourRole => 'Your role:';

  @override
  String get welcomeDescription => 'Thanks for joining! Access or create your account below, and get started on your journey!';
}
