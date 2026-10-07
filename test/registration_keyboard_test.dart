import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/enter_info_screen.dart';
import 'package:ping_my_therapist/screens/email_pw_screen.dart';

void main() {
  testWidgets(
    'registration fields keep focus and remain usable with keyboard',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(const MaterialApp(home: EnterInfoScreen()));

      final fields = find.byType(TextField);
      await tester.tap(fields.at(0));
      await tester.pump();
      expect(
        tester.widget<TextField>(fields.at(0)).focusNode!.hasFocus,
        isTrue,
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus,
        isTrue,
      );

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(fields.at(2)).focusNode!.hasFocus,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('registration flow validates details before account creation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EnterInfoScreen()));
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('Please fill in all fields.'), findsOneWidget);
    expect(find.byType(EmailPasswordScreen), findsNothing);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Amina');
    await tester.enterText(fields.at(1), '25');
    await tester.enterText(fields.at(2), 'Teacher');
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(EmailPasswordScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weak sign-up password is rejected before Firebase is called', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmailPasswordScreen(
          name: 'Amina',
          age: '25',
          occupation: 'Teacher',
        ),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'amina@example.com');
    await tester.enterText(fields.at(1), 'weak');
    await tester.ensureVisible(find.text('Continue Your Journey'));
    await tester.tap(find.text('Continue Your Journey'));
    await tester.pump();
    expect(find.textContaining('Use 8+ characters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
