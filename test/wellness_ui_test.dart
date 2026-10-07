import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/guided_breathing_screen.dart';
import 'package:ping_my_therapist/screens/journaling_screen.dart';
import 'package:ping_my_therapist/screens/mood_checkin_screen.dart';
import 'package:ping_my_therapist/screens/mood_tracker_screen.dart';
import 'package:ping_my_therapist/screens/name_what_you_feel_screen.dart';
import 'package:ping_my_therapist/widgets/pullable_section_header.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

void main() {
  testWidgets('card destination headers share a compact resting height', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: StretchySectionPage(
          title: 'Breathing exercises',
          subtitle: 'Find a steady rhythm that feels right for you.',
          leading: SizedBox(width: 48, height: 48),
          content: SizedBox(),
        ),
      ),
    );
    final scrollingHeight =
        tester
            .getSize(find.byKey(const ValueKey('stretchy-section-header')))
            .height;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PullableSectionHeader(
                title: 'Breathing exercises',
                subtitle: 'Find a steady rhythm that feels right for you.',
                leading: SizedBox(width: 48, height: 48),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    final fixedHeight =
        tester
            .getSize(find.byKey(const ValueKey('pullable-section-header')))
            .height;

    expect(scrollingHeight, lessThan(180));
    expect(fixedHeight, closeTo(scrollingHeight, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('home-style section header stretches and returns', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              PullableSectionHeader(
                title: 'Name What You Feel',
                subtitle: 'A quiet moment to understand what is here.',
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    final header = find.byKey(const ValueKey('pullable-section-header'));
    final initialHeight = tester.getSize(header).height;
    final gesture = await tester.startGesture(const Offset(160, 100));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(tester.getSize(header).height, greaterThan(initialHeight));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(header).height, closeTo(initialHeight, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('conversation header leaves more room after chat starts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Widget page({required bool compact}) => MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            PullableSectionHeader(
              title: 'Safe Space',
              subtitle: 'A quiet place to talk things through.',
              compact: compact,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back),
              ),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );

    final header = find.byKey(const ValueKey('pullable-section-header'));
    await tester.pumpWidget(page(compact: false));
    final fullHeight = tester.getSize(header).height;
    await tester.pumpWidget(page(compact: true));
    expect(tester.getSize(header).height, lessThan(fullHeight - 70));
    expect(find.text('Safe Space'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final screen in <(String, Widget)>[
    ('exercises', const BreathingExercisesScreen(showBackButton: false)),
    ('journaling', const JournalingScreen()),
  ]) {
    testWidgets('${screen.$1} fits phone widths and springs back', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      for (final size in [const Size(320, 640), const Size(430, 932)]) {
        tester.view.physicalSize = size;
        await tester.pumpWidget(MaterialApp(home: screen.$2));
        await tester.pumpAndSettle();

        final header = find.byKey(const ValueKey('stretchy-section-header'));
        final initialHeight = tester.getSize(header).height;
        final gesture = await tester.startGesture(const Offset(160, 150));
        await gesture.moveBy(const Offset(0, 120));
        await tester.pump();
        expect(tester.getSize(header).height, greaterThan(initialHeight));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(tester.getSize(header).height, closeTo(initialHeight, 1));
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('a journal prompt opens its writing page', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const MaterialApp(home: JournalingScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Values Check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Values Check-in'));
    await tester.pumpAndSettle();

    expect(find.text('Start writing here…'), findsOneWidget);
    expect(find.text('Save entry'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('every breathing introduction fits a narrow phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final exercise in breathingExercises) {
      await tester.pumpWidget(
        MaterialApp(
          home: BreathingExerciseIntroScreen(
            key: ValueKey(exercise.title),
            exercise: exercise,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Start guided breathing'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: exercise.title);
    }
  });

  testWidgets('quick mood check-in fits a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: MoodCheckinScreen()));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling?'), findsOneWidget);
    final header = find.byKey(const ValueKey('stretchy-section-header'));
    final initialHeight = tester.getSize(header).height;
    final gesture = await tester.startGesture(const Offset(160, 170));
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    expect(tester.getSize(header).height, greaterThan(initialHeight));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.getSize(header).height, closeTo(initialHeight, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mood tracker fits a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: MoodTrackerScreen(checkinsStream: Stream.value(const [])),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mood Tracker'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('name your feelings fits a narrow phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: NameWhatYouFeelScreen()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
