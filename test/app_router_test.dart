import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/app_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_theme.dart';

void main() {
  test('all primary destinations are registered exactly once', () {
    final paths = appRoutes.map((route) => route.path).toList();
    const expectedPaths = {
      RouteNames.splash,
      RouteNames.signup,
      RouteNames.login,
      RouteNames.enterInfo,
      RouteNames.onboardingQ1,
      RouteNames.home,
      RouteNames.chatbot,
      RouteNames.journaling,
      RouteNames.exercises,
      RouteNames.mood,
      RouteNames.appointments,
      RouteNames.music,
      RouteNames.nameWhatYouFeel,
    };

    expect(paths.toSet(), expectedPaths);
    expect(paths, hasLength(expectedPaths.length));
  });

  testWidgets('account entry routes to registration and login', (tester) async {
    final router = GoRouter(
      initialLocation: RouteNames.signup,
      routes: appRoutes,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router, theme: AppTheme.light),
    );
    await tester.pumpAndSettle();

    final createAccount = find.text('Create an account');
    await tester.ensureVisible(createAccount);
    await tester.tap(createAccount);
    await tester.pumpAndSettle();
    expect(find.text('Tell us about yourself'), findsOneWidget);

    router.go(RouteNames.signup);
    await tester.pumpAndSettle();
    final logIn = find.text('Log In');
    await tester.ensureVisible(logIn);
    await tester.tap(logIn);
    expect(router.state.uri.path, RouteNames.login);
  });
}
