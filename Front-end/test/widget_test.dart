import 'package:flutter_test/flutter_test.dart';
import 'package:pose_nova_ai/core/localization/app_language.dart';

void main() {
  test('Smoke test: AppLanguageController switches VI and EN correctly', () {
    final controller = AppLanguageController.instance;
    controller.setLanguage(AppLanguage.vi);
    expect(controller.current, AppLanguage.vi);
    expect(controller.isVietnamese, true);

    controller.setLanguage(AppLanguage.en);
    expect(controller.current, AppLanguage.en);
    expect(controller.isVietnamese, false);
  });
}
