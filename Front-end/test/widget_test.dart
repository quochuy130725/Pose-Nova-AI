import 'package:flutter_test/flutter_test.dart';
import 'package:pose_nova_ai/core/localization/app_language.dart';
import 'package:pose_nova_ai/main.dart';

void main() {
  testWidgets('PoseNovaApp smoke test launches LoginScreen with VI/EN switching', (WidgetTester tester) async {
    // Test English Mode
    AppLanguageController.instance.setLanguage(AppLanguage.en);
    await tester.pumpWidget(const PoseNovaApp());
    expect(find.text('PoseNova AI'), findsOneWidget);
    expect(find.text('Account Login'), findsOneWidget);

    // Test Vietnamese Mode
    AppLanguageController.instance.setLanguage(AppLanguage.vi);
    await tester.pump();
    expect(find.text('Đăng Nhập Tài Khoản'), findsOneWidget);
    expect(find.text('HOẶC CHỌN VAI TRÒ DEMO'), findsOneWidget);
  });
}
