import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_primary_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/onboarding_scaffold.dart';
import 'package:ping_my_therapist/widgets/onboarding/option_tile.dart';
import 'package:ping_my_therapist/widgets/onboarding/step_progress_bar.dart';

class OnboardingQ2Screen extends StatefulWidget {
  const OnboardingQ2Screen({super.key});

  @override
  State<OnboardingQ2Screen> createState() => _OnboardingQ2ScreenState();
}

class _OnboardingQ2ScreenState extends State<OnboardingQ2Screen> {
  static const _options = [
    'External pressure',
    'Peace of mind',
    'Self-growth',
    'Feeling seen',
  ];

  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingHeader(
            onBack: () => context.go(RouteNames.onboardingQ1),
            progress: const OnboardingStepProgress(activeStep: 1),
            badge: const StepBadge(number: 2),
            title: 'What motivates you the most right now?',
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              itemCount: _options.length,
              separatorBuilder: (_, __) => SizedBox(height: context.h(12)),
              itemBuilder: (context, index) {
                return OptionTile(
                  label: _options[index],
                  isSelected: _selectedIndex == index,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
      bottom: Padding(
        padding: context.insets(left: 24, top: 16, right: 24, bottom: 40),
        child: MoodiePrimaryButton(
          label: 'Next',
          trailingIconAsset: 'assets/icons/next_arrow.svg',
          enabled: _selectedIndex != null,
          onPressed: _selectedIndex != null
              ? () => context.go(RouteNames.onboardingQ3)
              : null,
        ),
      ),
    );
  }
}
