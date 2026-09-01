import 'package:flutter/material.dart';

import 'package:ping_my_therapist/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle _base({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Quicksand',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle splashTitle = _base(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -1,
    height: 1,
  );

  static TextStyle splashSubtitle = _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white.withValues(alpha: 0.82),
    letterSpacing: -0.3,
  );

  static TextStyle splashTagline = _base(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static TextStyle screenTitle = _base(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static TextStyle screenSubtitle = _base(
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  static TextStyle badge = _base(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle formTitle = _base(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static TextStyle formSubtitle = _base(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle fieldLabel = _base(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSubtle,
  );

  static TextStyle fieldInput = _base(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle fieldHint = _base(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  static TextStyle questionTitle = _base(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle stepNumber = _base(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle option = _base(fontSize: 15, fontWeight: FontWeight.w600);

  static TextStyle button = _base(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: -0.2,
  );

  static TextStyle buttonSmall = _base(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle divider = _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textDivider,
  );

  static TextStyle optionalHint = _base(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Color(0xFF999999),
  );

  static TextStyle textarea = _base(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle footerHint = _base(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textFaint,
  );
}
