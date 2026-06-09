import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';

class MoodieBackButton extends StatelessWidget {
  const MoodieBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = context.w(36);
    final radius = context.w(12);

    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/back_arrow.svg',
              width: context.w(18),
              height: context.h(15),
            ),
          ),
        ),
      ),
    );
  }
}
