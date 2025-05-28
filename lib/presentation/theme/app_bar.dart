import 'package:flutter/material.dart';

import 'color.dart';
import 'icon.dart';
import 'text.dart';

class AppBarStyles {
  final bool isDark;

  AppBarStyles(this.isDark);

  AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: isDark ? AppColor.darkBG_3 : AppColor.lightBG_3,
    iconTheme: AppIconThemes(isDark).appBarIcon,
    titleTextStyle: AppTextStyles(isDark).titleSmall.copyWith(color: AppColor.primaryColor),
  );
}
