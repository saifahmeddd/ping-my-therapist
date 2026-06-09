import 'package:flutter/material.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_back_button.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.body,
    this.bottom,
  });

  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}

class StepBadge extends StatelessWidget {
  const StepBadge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final size = context.w(48);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: context.radius(16),
      ),
      alignment: Alignment.center,
      child: Text('$number', style: AppTextStyles.stepNumber),
    );
  }
}

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.onBack,
    required this.progress,
    this.badge,
    required this.title,
    this.subtitle,
  });

  final VoidCallback onBack;
  final Widget progress;
  final Widget? badge;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.insets(left: 24, top: 8, right: 24, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoodieBackButton(onPressed: onBack),
          SizedBox(height: context.h(24)),
          progress,
          SizedBox(height: context.h(20)),
          if (badge != null) ...[
            badge!,
            SizedBox(height: context.h(16)),
          ],
          Text(title, style: AppTextStyles.questionTitle),
          if (subtitle != null) ...[
            SizedBox(height: context.h(6)),
            Text(subtitle!, style: AppTextStyles.optionalHint),
          ],
        ],
      ),
    );
  }
}
