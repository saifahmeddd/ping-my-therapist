import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_primary_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/onboarding_illustrations.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const _SplashHero(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: context.insets(
                    left: 28,
                    top: 40,
                    right: 28,
                    bottom: 48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _Dot(active: true),
                          SizedBox(width: context.w(8)),
                          const _Dot(active: false),
                          SizedBox(width: context.w(8)),
                          const _Dot(active: false),
                        ],
                      ),
                      SizedBox(height: context.h(24)),
                      Text(
                        'Your personal mood companion',
                        style: AppTextStyles.splashTagline,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(20)),
                      MoodiePrimaryButton(
                        label: 'Get Started',
                        onPressed: () => context.go(RouteNames.signup),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashHero extends StatelessWidget {
  const _SplashHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(context.w(56)),
        bottomRight: Radius.circular(context.w(56)),
      ),
      child: Container(
        height: context.h(420),
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.splashBand),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.65],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(32),
                MediaQuery.paddingOf(context).top + context.h(56),
                context.w(32),
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.splashTitle.copyWith(
                      fontSize: 34,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    'Stay in touch—with yourself',
                    style: AppTextStyles.splashSubtitle,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: context.h(-60),
              left: 0,
              right: 0,
              child: const Center(child: SplashIllustration()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final size = context.w(8);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.dotInactive,
        shape: BoxShape.circle,
      ),
    );
  }
}
