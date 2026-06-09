import 'package:flutter/material.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.activeStep,
    this.activeWidth = 24,
    this.inactiveWidth = 8,
  });

  final int totalSteps;
  final int activeStep;
  final double activeWidth;
  final double inactiveWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == activeStep;
        return Padding(
          padding: EdgeInsets.only(right: index < totalSteps - 1 ? context.w(6) : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: context.h(6),
            width: isActive ? context.w(activeWidth) : context.w(inactiveWidth),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class OnboardingStepProgress extends StatelessWidget {
  const OnboardingStepProgress({
    super.key,
    required this.activeStep,
  });

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == activeStep;
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? context.w(6) : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: context.h(6),
            width: context.w(24),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class EnterInfoStepProgress extends StatelessWidget {
  const EnterInfoStepProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const StepProgressBar(
      totalSteps: 4,
      activeStep: 0,
      activeWidth: 24,
      inactiveWidth: 8,
    );
  }
}
