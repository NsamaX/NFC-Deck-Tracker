import 'package:flutter/material.dart';

import 'color.dart';

class AppIconThemes {
  final bool isDark;

  AppIconThemes(this.isDark);

  IconThemeData get appBarIcon => IconThemeData(
        color: isDark ? AppColor.dark_core : AppColor.light_core,
        size: 24,
      );

  IconThemeData get defaultIcon => IconThemeData(
        color: isDark ? AppColor.dark_text : AppColor.light_text,
        size: 16,
      );
}
