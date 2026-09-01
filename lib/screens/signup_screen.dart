import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';
import 'package:ping_my_therapist/widgets/onboarding/moodie_primary_button.dart';
import 'package:ping_my_therapist/widgets/onboarding/onboarding_illustrations.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: context.insets(
                        left: 28,
                        top: 56,
                        right: 28,
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'No email needed',
                                  style: AppTextStyles.badge,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to\n${AppStrings.appName}',
                            style: AppTextStyles.screenTitle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "This is your space—let's make it feel like home. Just sign up and get started.",
                            style: AppTextStyles.screenSubtitle,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: context.radius(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const SignupIllustration(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: context.insets(left: 28, top: 24, right: 28, bottom: 40),
              child: Column(
                children: [
                  MoodiePrimaryButton(
                    label: 'Create an account',
                    onPressed: () => context.go(RouteNames.enterInfo),
                  ),
                  SizedBox(height: context.h(12)),
                  MoodiePrimaryButton(
                    label: 'Log In',
                    variant: MoodieButtonVariant.secondary,
                    onPressed: () => context.go(RouteNames.login),
                  ),
                  SizedBox(height: context.h(16)),
                  _SocialSignInRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialSignInRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.divider)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(12)),
              child: Text('or continue with', style: AppTextStyles.divider),
            ),
            Expanded(child: Divider(color: AppColors.divider)),
          ],
        ),
        SizedBox(height: context.h(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(child: _GoogleIcon()),
            SizedBox(width: context.w(16)),
            _SocialButton(
              child: Icon(
                Icons.apple,
                size: context.w(24),
                color: AppColors.textDark,
              ),
            ),
            SizedBox(width: context.w(16)),
            _SocialButton(
              child: Icon(
                Icons.facebook,
                size: context.w(28),
                color: Color(0xFF1877F2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = context.w(56);
    final radius = context.w(16);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.socialBorder, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = context.w(22);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 26.1332;
    canvas.scale(scale);
    final blue = Paint()..color = const Color(0xFF4285F4);
    final green = Paint()..color = const Color(0xFF34A853);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final red = Paint()..color = const Color(0xFFEA4335);

    canvas.drawPath(
      Path()
        ..moveTo(25.8081, 13.5791)
        ..cubicTo(25.8081, 12.6494, 25.7175, 11.9531, 25.5171, 11.2266)
        ..lineTo(13.2148, 11.2266)
        ..lineTo(13.2148, 15.5859)
        ..lineTo(20.0857, 15.5859)
        ..cubicTo(19.9551, 16.8047, 19.1953, 18.5625, 17.6177, 19.6406)
        ..lineTo(17.6177, 22.3359)
        ..lineTo(21.4785, 22.3359)
        ..cubicTo(24.0469, 20.0625, 25.8081, 17.1367, 25.8081, 13.5791)
        ..close(),
      blue,
    );
    canvas.drawPath(
      Path()
        ..moveTo(13.2012, 25.8086)
        ..cubicTo(16.418, 25.8086, 19.0312, 24.7969, 21.4785, 22.3359)
        ..lineTo(17.6177, 19.6406)
        ..cubicTo(16.582, 20.3203, 15.2344, 20.7422, 13.2012, 20.7422)
        ..cubicTo(9.31641, 20.7422, 6.03516, 18.2109, 4.875, 14.7422)
        ..lineTo(0.914062, 14.7422)
        ..lineTo(0.914062, 17.5078)
        ..cubicTo(3.33984, 22.2188, 7.94531, 25.8086, 13.2012, 25.8086)
        ..close(),
      green,
    );
    canvas.drawPath(
      Path()
        ..moveTo(4.875, 14.7422)
        ..cubicTo(4.58203, 13.8633, 4.40625, 12.9258, 4.40625, 11.9531)
        ..cubicTo(4.40625, 10.9805, 4.58203, 10.043, 4.875, 9.16406)
        ..lineTo(4.875, 6.39844)
        ..lineTo(0.914062, 6.39844)
        ..cubicTo(-0.105469, 8.4375, -0.105469, 10.9688, 0.914062, 13.0078)
        ..lineTo(4.875, 14.7422)
        ..close(),
      yellow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(13.2012, 3.16406)
        ..cubicTo(15.4102, 3.16406, 17.0508, 3.98438, 18.3984, 5.15625)
        ..lineTo(21.7969, 1.75781)
        ..cubicTo(19.0312, -0.175781, 16.418, -1.46484, 13.2012, -1.46484)
        ..cubicTo(7.94531, -1.46484, 3.33984, 2.125, 0.914062, 6.39844)
        ..lineTo(4.875, 9.16406)
        ..cubicTo(6.03516, 5.69531, 9.31641, 3.16406, 13.2012, 3.16406)
        ..close(),
      red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
