import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/screens/appointment_screen.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/chatbot_screen.dart';
import 'package:ping_my_therapist/screens/enter_info_screen.dart';
import 'package:ping_my_therapist/screens/home_page.dart';
import 'package:ping_my_therapist/screens/journaling_screen.dart';
import 'package:ping_my_therapist/screens/login_screen.dart';
import 'package:ping_my_therapist/screens/mood_checkin_screen.dart';
import 'package:ping_my_therapist/screens/music_recommendation_screen.dart';
import 'package:ping_my_therapist/screens/name_what_you_feel_screen.dart';
import 'package:ping_my_therapist/screens/onboarding_q1_screen.dart';
import 'package:ping_my_therapist/screens/signup_login_screen.dart';
import 'package:ping_my_therapist/screens/splash_screen.dart';

final appRoutes = <GoRoute>[
  GoRoute(
    path: RouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: RouteNames.signup,
    builder: (context, state) => const SignupLoginScreen(),
  ),
  GoRoute(
    path: RouteNames.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: RouteNames.enterInfo,
    builder: (context, state) => const EnterInfoScreen(),
  ),
  GoRoute(
    path: RouteNames.onboardingQ1,
    builder: (context, state) => const OnboardingQuestionOneScreen(),
  ),
  GoRoute(
    path: RouteNames.home,
    builder: (context, state) {
      final initialIndex = switch (state.uri.queryParameters['tab']) {
        'tracker' => 1,
        'exercises' => 2,
        'profile' => 3,
        _ => 0,
      };
      return HomePage(initialIndex: initialIndex);
    },
  ),
  GoRoute(
    path: RouteNames.chatbot,
    builder: (context, state) => const ChatbotScreen(),
  ),
  GoRoute(
    path: RouteNames.journaling,
    builder: (context, state) => const JournalingScreen(),
  ),
  GoRoute(
    path: RouteNames.exercises,
    builder: (context, state) => const BreathingExercisesScreen(),
  ),
  GoRoute(
    path: RouteNames.mood,
    redirect: (context, state) => '${RouteNames.home}?tab=tracker',
  ),
  GoRoute(
    path: RouteNames.moodCheckin,
    builder: (context, state) => MoodCheckinScreen(returnToTracker: true),
  ),
  GoRoute(
    path: RouteNames.appointments,
    builder: (context, state) => const AppointmentScreen(),
  ),
  GoRoute(
    path: RouteNames.music,
    builder: (context, state) => const MusicRecommendationScreen(),
  ),
  GoRoute(
    path: RouteNames.nameWhatYouFeel,
    builder: (context, state) => const NameWhatYouFeelScreen(),
  ),
];

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: appRoutes,
    redirect: (context, state) {
      User? user;
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (_) {
        // Firebase is always initialized by main in production. Keeping the
        // router buildable without it makes isolated widget tests possible.
      }

      const publicPaths = {
        RouteNames.splash,
        RouteNames.signup,
        RouteNames.login,
        RouteNames.enterInfo,
        RouteNames.onboardingQ1,
      };
      final isProtected = !publicPaths.contains(state.uri.path);
      if (user == null && isProtected) return RouteNames.signup;
      return null;
    },
    errorBuilder: (context, state) => const _RouteErrorScreen(),
  );
});

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_off_rounded, size: 52),
                const SizedBox(height: 16),
                const Text(
                  'We could not find that page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go(RouteNames.splash),
                  child: const Text('Back to start'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
