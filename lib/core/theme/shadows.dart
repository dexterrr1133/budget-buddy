import 'package:flutter/material.dart';
import 'colors.dart';

class AppShadows {
  static const lightCard = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const darkCard = [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const subtle = [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const floating = [
    BoxShadow(
      color: AppColors.primaryShadow,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> card(bool isDark) => isDark ? darkCard : lightCard;
}
