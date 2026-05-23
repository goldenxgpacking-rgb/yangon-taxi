import 'package:flutter/material.dart';

class AppColors {
  // 主色调 - 仰光金
  static const primary = Color(0xFFFDD700);
  static const primaryDark = Color(0xFFC9A800);
  
  // 辅色 - 深蓝黑
  static const secondary = Color(0xFF1A1A2E);
  static const secondaryLight = Color(0xFF2D2D44);
  
  // 功能色
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);
  
  // 中性色
  static const white = Color(0xFFFFFFFF);
  static const lightGrey = Color(0xFFF5F5F5);
  static const grey = Color(0xFF9E9E9E);
  static const darkGrey = Color(0xFF616161);
  static const black = Color(0xFF000000);
  
  // 渐变
  static const gradientStart = Color(0xFFFDD700);
  static const gradientEnd = Color(0xFFFFF176);
}

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );
  
  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );
  
  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.secondary,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.secondary,
  );
  
  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );
  
  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppDimensions {
  static const paddingSmall = 8.0;
  static const paddingMedium = 16.0;
  static const paddingLarge = 24.0;
  static const paddingXLarge = 32.0;
  
  static const borderRadius = 12.0;
  static const borderRadiusLarge = 20.0;
  
  static const iconSize = 24.0;
  static const iconSizeLarge = 32.0;
}
