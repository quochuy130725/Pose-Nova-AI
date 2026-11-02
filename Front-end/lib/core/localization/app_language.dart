import 'app_strings.dart';

export 'app_strings.dart';

/// Legacy bridge for existing references to AppLanguageController
class AppLanguageController {
  static LocaleController get instance => LocaleController.instance;
}

typedef AppTranslations = AppStrings;
