import 'package:flutter/material.dart';

import 'color.dart';

class AppBottomNavBarStyles {
  final bool isDark;

  AppBottomNavBarStyles(this.isDark);

  BottomNavigationBarThemeData get bottomNavBarTheme => BottomNavigationBarThemeData(
    backgroundColor: isDark ? AppColor.darkBG_1 : AppColor.lightBG_1,
    selectedItemColor: AppColor.primaryColor,
    unselectedItemColor: AppColor.opacityText,
  );
}
