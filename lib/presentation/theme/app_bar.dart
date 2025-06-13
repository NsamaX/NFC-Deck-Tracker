import 'package:flutter/material.dart';

import 'color.dart';
import 'icon.dart';
import 'text.dart';

class AppBarStyles {
  final bool isDark;

  AppBarStyles(this.isDark);

  AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: isDark ? AppColor.dark_3 : AppColor.light_2,
    iconTheme: AppIconThemes(isDark).appBarIcon,
    titleTextStyle: AppTextStyles(isDark).titleSmall,
  );
}
