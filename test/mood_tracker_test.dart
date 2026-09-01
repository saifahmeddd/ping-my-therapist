import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ping_my_therapist/screens/home_page.dart';
import 'package:ping_my_therapist/screens/mood_tracker_screen.dart';

void main() {
  test('mood records normalize both tracker formats', () {
    final detailed = MoodCheckinEntry.fromMap({
      'displayMood': 'Bright',
      'moodScale': 1,
      'emotions': ['Hopeful'],
      'timestamp': DateTime(2026, 8, 28),
    });
    final quick = MoodCheckinEntry.fromMap({
      'moods': ['Heavy & Drowning'],
      'timestamp': DateTime(2026, 8, 27),
    });

    expect(detailed.label, 'Bright');
    expect(detailed.wellbeingScore, 5);
    expect(detailed.emotions, ['Hopeful']);
    expect(quick.label, 'Heavy & Drowning');
    expect(quick.wellbeingScore, 1);
  });

  testWidgets('tracker presents actions, week pattern, and recent history', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final now = DateTime.now();
    final entries = [
      MoodCheckinEntry(
        label: 'Bright',
        wellbeingScore: 5,
        timestamp: now,
        emotions: const ['Hopeful', 'Calm'],
      ),
      MoodCheckinEntry(
        label: 'Unsure',
        wellbeingScore: 3,
        timestamp: now.subtract(const Duration(days: 1)),
        emotions: const ['Distant'],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: MoodTrackerScreen(checkinsStream: Stream.value(entries)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mood Tracker'), findsOneWidget);
    expect(find.text('Quick check-in'), findsOneWidget);
    expect(find.text('Name feelings'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
    expect(find.text('2 day streak'), findsOneWidget);
    expect(find.text('Latest reflection'), findsNothing);
    expect(find.text('LATEST REFLECTION'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent check-ins'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent check-ins'), findsOneWidget);
  });

  testWidgets('navbar keeps four stable tabs and respects initial selection', (
    tester,
  ) async {
    final screens = List.generate(
      4,
      (index) => ColoredBox(key: ValueKey('tab-$index'), color: Colors.white),
    );

    await tester.pumpWidget(
      MaterialApp(home: HomePage(initialIndex: 1, tabScreens: screens)),
    );

    NavigationBar navbar = tester.widget(find.byType(NavigationBar));
    expect(navbar.destinations, hasLength(4));
    expect(navbar.selectedIndex, 1);

    await tester.tap(find.text('Exercises'));
    await tester.pump();
    navbar = tester.widget(find.byType(NavigationBar));
    expect(navbar.selectedIndex, 2);
  });
}
