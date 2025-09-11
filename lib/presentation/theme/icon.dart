import 'package:flutter/material.dart';

import 'color.dart';

class AppIconThemes {
  static final AppIconThemes light = AppIconThemes._(isDark: false);
  static final AppIconThemes dark = AppIconThemes._(isDark: true);

  final IconThemeData appBarIcon;
  final IconThemeData defaultIcon;

  AppIconThemes._({required bool isDark})
      : appBarIcon = IconThemeData(
          color: isDark ? AppColor.darkCore : AppColor.lightCore,
          size: 24,
        ),
        defaultIcon = IconThemeData(
          color: isDark ? AppColor.darkText : AppColor.lightText,
          size: 16,
        );
}
