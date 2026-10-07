import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ping_my_therapist/screens/email_pw_screen.dart';
import 'package:ping_my_therapist/screens/enter_info_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('patient enters details and reaches account credentials', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EnterInfoScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Amina');
    await tester.enterText(fields.at(1), '25');
    await tester.enterText(fields.at(2), 'Teacher');
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(EmailPasswordScreen), findsOneWidget);
    expect(
      tester.widgetList<TextField>(find.byType(TextField)).any(
        (field) => field.decoration?.hintText == 'Create a strong password',
      ),
      isTrue,
    );
  });
}
