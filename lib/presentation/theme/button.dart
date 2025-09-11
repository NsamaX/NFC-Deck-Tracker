import 'package:flutter/material.dart';

import 'color.dart';
import 'text.dart';

class AppButtonStyles {
  AppButtonStyles._();

  static final ButtonStyle lightElevated = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColor.lightText),
    foregroundColor: WidgetStateProperty.all(AppColor.lightCore),
    textStyle: WidgetStateProperty.all(AppTextStyles.light.bodyLarge),
  );

  static final ButtonStyle darkElevated = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColor.darkText),
    foregroundColor: WidgetStateProperty.all(AppColor.darkCore),
    textStyle: WidgetStateProperty.all(AppTextStyles.dark.bodyLarge),
  );
}
