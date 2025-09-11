import 'package:flutter/material.dart';

import 'color.dart';
import 'icon.dart';
import 'text.dart';

class AppBarStyles {
  AppBarStyles._();

  static final AppBarTheme light = AppBarTheme(
    backgroundColor: AppColor.light2,
    iconTheme: AppIconThemes.light.appBarIcon,
    titleTextStyle: AppTextStyles.light.titleSmall,
  );

  static final AppBarTheme dark = AppBarTheme(
    backgroundColor: AppColor.dark3,
    iconTheme: AppIconThemes.dark.appBarIcon,
    titleTextStyle: AppTextStyles.dark.titleSmall,
  );
}
