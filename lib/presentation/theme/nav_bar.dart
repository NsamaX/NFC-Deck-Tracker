import 'package:flutter/material.dart';

import 'color.dart';

class AppBottomNavBarStyles {
  final bool isDark;

  AppBottomNavBarStyles(this.isDark);

  BottomNavigationBarThemeData get bottomNavBarTheme => BottomNavigationBarThemeData(
    backgroundColor: isDark ? AppColor.dark_1 : AppColor.light_2,
    selectedItemColor: isDark ? AppColor.dark_core : AppColor.light_core,
    unselectedItemColor: AppColor.opacity_text,
  );
}
