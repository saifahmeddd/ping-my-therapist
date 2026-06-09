import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.w(16);

    return Material(
      color: isSelected ? AppColors.primary : AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: context.h(52),
          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected ? AppColors.primaryLight : AppColors.borderLight,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isSelected ? 16 : 4,
                offset: Offset(0, isSelected ? context.h(4) : context.h(1)),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: context.w(20),
                height: context.w(20),
                child: Center(
                  child: isSelected
                      ? SvgPicture.asset(
                          'assets/icons/checkmark.svg',
                          width: context.w(16),
                          height: context.h(12),
                        )
                      : Container(
                          width: context.w(16),
                          height: context.w(16),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
              SizedBox(width: context.w(12)),
              Text(
                label,
                style: AppTextStyles.option.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
