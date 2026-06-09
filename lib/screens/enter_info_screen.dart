import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_back_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_primary_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_text_field.dart';
import 'package:ping_my_therapist/widgets/onboarding/onboarding_scaffold.dart';
import 'package:ping_my_therapist/widgets/onboarding/step_progress_bar.dart';

class EnterInfoScreen extends StatefulWidget {
  const EnterInfoScreen({super.key});

  @override
  State<EnterInfoScreen> createState() => _EnterInfoScreenState();
}

class _EnterInfoScreenState extends State<EnterInfoScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    return _nameController.text.trim().isNotEmpty &&
        _ageController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: context.insets(left: 24, top: 8, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoodieBackButton(
                    onPressed: () => context.go(RouteNames.signup),
                  ),
                  SizedBox(height: context.h(24)),
                  const EnterInfoStepProgress(),
                  SizedBox(height: context.h(20)),
                  Text('Tell us about yourself', style: AppTextStyles.formTitle),
                  SizedBox(height: context.h(6)),
                  Text(
                    "We'll personalise your experience to suit you.",
                    style: AppTextStyles.formSubtitle,
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Column(
                children: [
                  MoodieTextField(
                    label: 'What should we call you?',
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.h(16)),
                  MoodieTextField(
                    label: 'How old are you?',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.h(16)),
                  MoodieTextField(
                    label: 'What do you do?',
                    controller: _occupationController,
                    placeholder: 'Occupation',
                    hint: "Helps us understand what you're balancing",
                    hintIconAsset: 'assets/icons/info_circle.svg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: Padding(
        padding: context.insets(left: 24, top: 16, right: 24, bottom: 40),
        child: MoodiePrimaryButton(
          label: 'Next',
          trailingIconAsset: 'assets/icons/next_arrow.svg',
          enabled: _canContinue,
          onPressed: _canContinue
              ? () => context.go(RouteNames.onboardingQ1)
              : null,
        ),
      ),
    );
  }
}
