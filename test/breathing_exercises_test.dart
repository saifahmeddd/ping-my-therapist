import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/guided_breathing_screen.dart';

void main() {
  group('breathing exercises', () {
    test('all exercises have complete, usable guidance', () {
      expect(breathingExercises, hasLength(7));

      for (final exercise in breathingExercises) {
        expect(exercise.title, isNotEmpty);
        expect(exercise.shortDuration, isNotEmpty);
        expect(exercise.focusArea, isNotEmpty);
        expect(exercise.description, isNotEmpty);
        expect(exercise.preparation, isNotEmpty);
        expect(exercise.tip, isNotEmpty);
        expect(exercise.cycles, greaterThan(0));
        expect(exercise.phases, isNotEmpty);
        expect(exercise.totalSeconds, greaterThan(0));

        for (final phase in exercise.phases) {
          expect(phase.seconds, greaterThan(0));
          expect(phase.startScale, inInclusiveRange(0.0, 1.0));
          expect(phase.endScale, inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('timed exercises match their displayed duration', () {
      final timedExercises = <String, int>{
        'Box Breathing': 4 * 60,
        'Tactical Breathing': 5 * 60,
        'Double Inhale and Sigh': 2 * 60,
        'Diaphragmatic Breathing': 5 * 60,
        '3-3-3 Breathing': 3 * 60,
        'Coherent Breathing': 6 * 60,
      };

      for (final entry in timedExercises.entries) {
        final exercise = breathingExercises.singleWhere(
          (exercise) => exercise.title == entry.key,
        );
        expect(exercise.totalSeconds, entry.value, reason: entry.key);
      }
    });

    test('hold detection only applies to full and empty holds', () {
      expect(holdFull4.isHold, isTrue);
      expect(holdEmpty4.isHold, isTrue);
      expect(inhale4.isHold, isFalse);
      expect(exhale4.isHold, isFalse);
    });

    test('each named technique uses its intended phase timing', () {
      expect(_patternFor('Box Breathing'), [4, 4, 4, 4]);
      expect(_patternFor('4-7-8 Breathing'), [4, 7, 8]);
      expect(_patternFor('Tactical Breathing'), [4, 6]);
      expect(_patternFor('Double Inhale and Sigh'), [2, 1, 5]);
      expect(_patternFor('Diaphragmatic Breathing'), [2, 4]);
      expect(_patternFor('3-3-3 Breathing'), [3, 3, 3]);
      expect(_patternFor('Coherent Breathing'), [5, 5]);
    });
  });

  group('breathing exercise cards', () {
    testWidgets('all cards use the same dimensions', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 3000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(home: BreathingExercisesScreen()),
      );
      await tester.pumpAndSettle();

      final sizes = <Size>[];
      for (final exercise in breathingExercises) {
        final card = find.byKey(ValueKey('breathing-card-${exercise.title}'));
        expect(card, findsOneWidget);
        sizes.add(tester.getSize(card));
      }

      expect(sizes.toSet(), hasLength(1));
    });

    testWidgets('a card opens the matching exercise introduction', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: BreathingExercisesScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('breathing-card-Box Breathing')),
      );
      await tester.pumpAndSettle();

      expect(find.text('How it works'), findsOneWidget);
      expect(find.text('4 · 4 · 4 · 4 second rhythm'), findsOneWidget);
    });
  });
}

List<int> _patternFor(String title) {
  return breathingExercises
      .singleWhere((exercise) => exercise.title == title)
      .phases
      .map((phase) => phase.seconds)
      .toList();
}
