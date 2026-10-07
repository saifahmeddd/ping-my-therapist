import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/screens/mood_checkin_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

GoRouter _testRouter(
  String initialLocation, {
  Future<void> Function(List<String>)? saveCheckin,
}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: RouteNames.home,
      builder:
          (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push(RouteNames.moodCheckin),
                child: const Text('Open check-in'),
              ),
            ),
          ),
    ),
    GoRoute(
      path: RouteNames.moodCheckin,
      builder:
          (context, state) => MoodCheckinScreen(
            returnToTracker: true,
            saveCheckin: saveCheckin,
          ),
    ),
  ],
);

void main() {
  testWidgets('check-in back arrow returns to tracker from a pushed route', (
    tester,
  ) async {
    final router = _testRouter(RouteNames.home);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open check-in'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CustomBackButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, RouteNames.home);
    expect(router.state.uri.queryParameters['tab'], 'tracker');
  });

  testWidgets('Android back returns to tracker from a pushed check-in', (
    tester,
  ) async {
    final router = _testRouter(RouteNames.home);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Open check-in'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.uri.path, RouteNames.home);
    expect(router.state.uri.queryParameters['tab'], 'tracker');
  });

  testWidgets('check-in opened directly has a safe back destination', (
    tester,
  ) async {
    final router = _testRouter(RouteNames.moodCheckin);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.state.uri.path, RouteNames.home);
    expect(router.state.uri.queryParameters['tab'], 'tracker');
  });

  testWidgets('failed check-in remains available and saves on retry', (
    tester,
  ) async {
    var attempts = 0;
    final savedMoods = <List<String>>[];
    final router = _testRouter(
      RouteNames.moodCheckin,
      saveCheckin: (moods) async {
        attempts++;
        if (attempts == 1) throw Exception('Firestore unavailable');
        savedMoods.add(moods);
      },
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Light & Clear'));
    await tester.ensureVisible(find.text('Save check-in'));
    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, RouteNames.moodCheckin);
    expect(
      find.text('Could not save your check-in. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Save check-in'));
    await tester.pumpAndSettle();
    expect(savedMoods, [
      ['Light & Clear'],
    ]);
    expect(router.state.uri.path, RouteNames.home);
  });
}
