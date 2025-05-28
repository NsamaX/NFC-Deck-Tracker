import 'package:flutter/material.dart';

import 'color.dart';

class AppIconThemes {
  final bool isDark;

  AppIconThemes(this.isDark);

  IconThemeData get appBarIcon => const IconThemeData(
    color: AppColor.primaryColor,
    size: 24,
  );

  IconThemeData get defaultIcon => IconThemeData(
    color: isDark ? AppColor.darkText : AppColor.lightText,
    size: 16,
  );
}
