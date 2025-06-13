import 'package:flutter/material.dart';

import 'color.dart';

class AppProgressIndicatorStyles {
  final bool isDark;

  AppProgressIndicatorStyles(this.isDark);

  ProgressIndicatorThemeData get progressIndicatorTheme => ProgressIndicatorThemeData(
    color: isDark ? AppColor.dark_core : AppColor.light_core,
    refreshBackgroundColor: isDark ? AppColor.dark_3 : AppColor.light_3,
    circularTrackColor: isDark ? AppColor.dark_2 : AppColor.light_2,
  );
}
