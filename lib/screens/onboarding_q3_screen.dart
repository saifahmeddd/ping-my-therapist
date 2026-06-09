import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_primary_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/onboarding_scaffold.dart';
import 'package:ping_my_therapist/widgets/onboarding/step_progress_bar.dart';

class OnboardingQ3Screen extends StatefulWidget {
  const OnboardingQ3Screen({super.key});

  @override
  State<OnboardingQ3Screen> createState() => _OnboardingQ3ScreenState();
}

class _OnboardingQ3ScreenState extends State<OnboardingQ3Screen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingHeader(
            onBack: () => context.go(RouteNames.onboardingQ2),
            progress: const OnboardingStepProgress(activeStep: 2),
            badge: const StepBadge(number: 3),
            title: "Anything else you'd like to tell?",
            subtitle: 'Optional — skip if you prefer.',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Additional Context', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: _focused
                              ? AppColors.white
                              : AppColors.inputBackground,
                          borderRadius: context.radius(16),
                          border: Border.all(
                            color: _focused
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: _focused
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 0,
                                    spreadRadius: 3,
                                  ),
                                ]
                              : null,
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          maxLines: 5,
                          style: AppTextStyles.textarea,
                          decoration: InputDecoration(
                            hintText: 'What are your likes and dislikes?',
                            hintStyle: AppTextStyles.textarea.copyWith(
                              color: AppColors.textHint,
                            ),
                            contentPadding: EdgeInsets.all(context.w(16)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Positioned(
                        right: context.w(8),
                        bottom: context.h(8),
                        child: Icon(
                          Icons.open_in_full_rounded,
                          size: context.w(16),
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share anything that helps us understand you better',
                    style: AppTextStyles.footerHint,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottom: Padding(
        padding: context.insets(left: 24, top: 16, right: 24, bottom: 40),
        child: MoodiePrimaryButton(
          label: 'Finish',
          trailingIconAsset: 'assets/icons/finish_arrow.svg',
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
    );
  }
}
