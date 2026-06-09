import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/screens/enter_info_screen.dart';
import 'package:ping_my_therapist/screens/home_screen.dart';
import 'package:ping_my_therapist/screens/onboarding_q1_screen.dart';
import 'package:ping_my_therapist/screens/onboarding_q2_screen.dart';
import 'package:ping_my_therapist/screens/onboarding_q3_screen.dart';
import 'package:ping_my_therapist/screens/signup_screen.dart';
import 'package:ping_my_therapist/screens/splash_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.enterInfo,
        builder: (context, state) => const EnterInfoScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingQ1,
        builder: (context, state) => const OnboardingQ1Screen(),
      ),
      GoRoute(
        path: RouteNames.onboardingQ2,
        builder: (context, state) => const OnboardingQ2Screen(),
      ),
      GoRoute(
        path: RouteNames.onboardingQ3,
        builder: (context, state) => const OnboardingQ3Screen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
