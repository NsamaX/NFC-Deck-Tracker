import 'package:flutter/material.dart';

import 'color.dart';

class AppProgressIndicatorStyles {
  final bool isDark;

  AppProgressIndicatorStyles(this.isDark);

  ProgressIndicatorThemeData get progressIndicatorTheme => ProgressIndicatorThemeData(
    color: AppColor.primaryColor,
    refreshBackgroundColor: isDark ? AppColor.darkBG_3 : AppColor.lightBG_3,
    circularTrackColor: isDark ? AppColor.darkBG_2 : AppColor.lightBG_2,
  );
}
