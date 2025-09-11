import 'package:flutter/material.dart';

import 'color.dart';

class AppBottomNavBarStyles {
  AppBottomNavBarStyles._();

  static final BottomNavigationBarThemeData light = BottomNavigationBarThemeData(
    backgroundColor: AppColor.light2,
    selectedItemColor: AppColor.lightCore,
    unselectedItemColor: AppColor.opacityText,
  );

  static final BottomNavigationBarThemeData dark = BottomNavigationBarThemeData(
    backgroundColor: AppColor.dark1,
    selectedItemColor: AppColor.darkCore,
    unselectedItemColor: AppColor.opacityText,
  );
}
