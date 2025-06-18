import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'button.dart';
import 'color.dart';
import 'icon.dart';
import 'nav_bar.dart';
import 'progress_indicator.dart';
import 'text.dart';

extension CustomColorScheme on ColorScheme {
  Color get tutorial     => AppColor.tutorial;
  Color get active       => AppColor.active;
  Color get success      => AppColor.success;
  Color get warning      => AppColor.warning;
  Color get error        => AppColor.error;

  Color get pin_color_1  => AppColor.pin_color_1;
  Color get pin_color_2  => AppColor.pin_color_2;
  Color get pin_color_3  => AppColor.pin_color_3;

  Color get opacity_text => AppColor.opacity_text;
}

ThemeData AppTheme(
  bool isDark,
) {
  return ThemeData(
    scaffoldBackgroundColor: isDark ? AppColor.dark_2 : AppColor.light_1,
    iconTheme: AppIconThemes(isDark).defaultIcon,
    textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
      titleLarge: AppTextStyles(isDark).titleLarge,
      titleMedium: AppTextStyles(isDark).titleMedium,
      titleSmall: AppTextStyles(isDark).titleSmall,
      bodyLarge: AppTextStyles(isDark).bodyLarge,
      bodyMedium: AppTextStyles(isDark).bodyMedium,
      bodySmall: AppTextStyles(isDark).bodySmall,
    ),
    appBarTheme: AppBarStyles(isDark).appBarTheme,
    bottomNavigationBarTheme: AppBottomNavBarStyles(isDark).bottomNavBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles(isDark).elevatedButton,
    ),
    progressIndicatorTheme: AppProgressIndicatorStyles(isDark).progressIndicatorTheme,
  );
}
