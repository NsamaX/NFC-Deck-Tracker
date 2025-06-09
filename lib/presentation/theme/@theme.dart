import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'button.dart';
import 'color.dart';
import 'icon.dart';
import 'nav_bar.dart';
import 'progress_indicator.dart';
import 'text.dart';

extension CustomColorScheme on ColorScheme {
  Color get opacityText => AppColor.opacityText;
}

ThemeData AppTheme(
  bool isDark,
) {
  return ThemeData(
    scaffoldBackgroundColor: isDark
        ? AppColor.darkBG_2
        : AppColor.lightBG_2,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColor.primaryColor,
      secondary: AppColor.secondaryColor,
      tertiary: AppColor.tertiaryColor,
      error: CupertinoColors.systemRed,
      surface: Colors.white,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onTertiary: Colors.black,
      onError: Colors.black,
      onSurface: AppColor.opacityText,
    ),

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
