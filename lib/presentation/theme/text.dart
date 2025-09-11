import 'package:flutter/material.dart';

import 'color.dart';

class AppTextStyles {
  static final AppTextStyles light = AppTextStyles._(isDark: false);
  static final AppTextStyles dark = AppTextStyles._(isDark: true);

  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  AppTextStyles._({required bool isDark})
      : this.from(color: isDark ? AppColor.darkText : AppColor.lightText);

  AppTextStyles.from({required Color color})
      : titleLarge  = _createTextStyle(color: color, fontSize: 60, isBold: true),
        titleMedium = _createTextStyle(color: color, fontSize: 20, isBold: true),
        titleSmall  = _createTextStyle(color: color, fontSize: 10, isBold: true),
        bodyLarge   = _createTextStyle(color: color, fontSize: 30),
        bodyMedium  = _createTextStyle(color: color, fontSize: 14),
        bodySmall   = _createTextStyle(color: color, fontSize: 10);

  static TextStyle _createTextStyle({
    required Color color,
    required double fontSize,
    bool isBold = false,
  }) =>
      TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'PlaypenSansThai',
      );
}
