import 'package:flutter/material.dart';

import 'color.dart';

class AppProgressIndicatorStyles {
  AppProgressIndicatorStyles._();

  static final ProgressIndicatorThemeData light = ProgressIndicatorThemeData(
    color: AppColor.lightCore,
    refreshBackgroundColor: AppColor.light3,
    circularTrackColor: AppColor.light2,
  );

  static final ProgressIndicatorThemeData dark = ProgressIndicatorThemeData(
    color: AppColor.darkCore,
    refreshBackgroundColor: AppColor.dark3,
    circularTrackColor: AppColor.dark2,
  );
}
