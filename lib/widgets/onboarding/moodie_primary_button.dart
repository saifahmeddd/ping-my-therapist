import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';

enum MoodieButtonVariant { primary, secondary }

class MoodiePrimaryButton extends StatelessWidget {
  const MoodiePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MoodieButtonVariant.primary,
    this.trailingIconAsset,
    this.designHeight = 54,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final MoodieButtonVariant variant;
  final String? trailingIconAsset;
  final double designHeight;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == MoodieButtonVariant.primary;
    final isEnabled = enabled && onPressed != null;
    final height = context.h(designHeight);
    final radius = context.w(16);
    final foreground = isPrimary ? AppColors.white : AppColors.primary;

    return Opacity(
      opacity: isEnabled ? 1 : 0.45,
      child: Material(
        color: isPrimary ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        elevation: 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.borderSecondary, width: 1.5),
              boxShadow: isPrimary && isEnabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        blurRadius: 24,
                        offset: Offset(0, context.h(8)),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.buttonSmall.copyWith(color: foreground),
                ),
                if (trailingIconAsset != null) ...[
                  SizedBox(width: context.w(12)),
                  SvgPicture.asset(
                    trailingIconAsset!,
                    width: context.w(14),
                    height: context.h(12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
