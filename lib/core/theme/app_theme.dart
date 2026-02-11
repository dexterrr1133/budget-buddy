import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightDivider,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.lightSurface,
      error: AppColors.expense,
    ),

    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelSmall: AppTextStyles.label.copyWith(
        color: AppColors.lightTextSecondary,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightCard,
      shadowColor: AppColors.shadowLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      error: AppColors.expense,
    ),

    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelSmall: AppTextStyles.label.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkCard,
      shadowColor: AppColors.shadowDark,
    ),
  );
}
