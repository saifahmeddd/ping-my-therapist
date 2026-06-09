import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: TextTheme(
        bodyMedium: AppTextStyles.fieldInput,
      ),
    );
  }
}
