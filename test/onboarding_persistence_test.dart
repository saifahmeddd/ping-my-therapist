import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/success_screen.dart';

void main() {
  testWidgets('onboarding blocks completion until answers are saved', (
    tester,
  ) async {
    const answers = {
      'answer1': 'Reach out',
      'answer2': 'Finding balance',
      'additional_context': 'I want to sleep better',
    };
    var attempts = 0;
    Map<String, dynamic>? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: SuccessScreen(
          userAnswers: answers,
          saveAnswers: (value) async {
            attempts++;
            if (attempts == 1) throw Exception('Offline');
            saved = value;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry saving'), findsOneWidget);
    expect(find.text('Start Your Journey'), findsNothing);
    await tester.tap(find.text('Retry saving'));
    await tester.pumpAndSettle();

    expect(saved, answers);
    expect(find.text('Start Your Journey'), findsOneWidget);
  });
}
