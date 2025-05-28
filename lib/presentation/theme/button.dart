import 'package:flutter/material.dart';

import 'color.dart';
import 'text.dart';

class AppButtonStyles {
  final bool isDark;

  AppButtonStyles(this.isDark);

  ButtonStyle get elevatedButton => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(isDark ? AppColor.darkText : AppColor.lightText),
    textStyle: WidgetStateProperty.all(AppTextStyles(isDark).bodyLarge),
  );
}
