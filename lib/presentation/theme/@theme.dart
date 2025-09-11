import 'package:flutter/material.dart';

import 'app_bar.dart';
import 'button.dart';
import 'color.dart';
import 'icon.dart';
import 'nav_bar.dart';
import 'progress_indicator.dart';
import 'text.dart';

extension CustomColorScheme on ColorScheme {
  Color get active      => AppColor.active;
  Color get success     => AppColor.success;
  Color get warning     => AppColor.warning;
  Color get error       => AppColor.error;

  Color get pinColor1   => AppColor.pinColor1;
  Color get pinColor2   => AppColor.pinColor2;
  Color get pinColor3   => AppColor.pinColor3;

  Color get opacityText => AppColor.opacityText;
  Color get tutorial    => AppColor.tutorial;
}

class AppThemes {
  AppThemes._();

  static final ThemeData light = _createTheme(isDark: false);
  static final ThemeData dark = _createTheme(isDark: true);

  static ThemeData _createTheme({required bool isDark}) {
    final baseTheme = ThemeData.light();
    final textStyles = isDark ? AppTextStyles.dark : AppTextStyles.light;

    return baseTheme.copyWith(
      scaffoldBackgroundColor: isDark ? AppColor.dark2 : AppColor.light1,
      iconTheme: isDark ? AppIconThemes.dark.defaultIcon : AppIconThemes.light.defaultIcon,
      appBarTheme: isDark ? AppBarStyles.dark : AppBarStyles.light,
      bottomNavigationBarTheme: isDark ? AppBottomNavBarStyles.dark : AppBottomNavBarStyles.light,
      progressIndicatorTheme: isDark ? AppProgressIndicatorStyles.dark : AppProgressIndicatorStyles.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: isDark ? AppButtonStyles.darkElevated : AppButtonStyles.lightElevated,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        titleLarge: textStyles.titleLarge,
        titleMedium: textStyles.titleMedium,
        titleSmall: textStyles.titleSmall,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyMedium,
        bodySmall: textStyles.bodySmall,
      ),
    );
  }
}
