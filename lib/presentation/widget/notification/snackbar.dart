import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant/ui.dart';

enum SnackBarType { success, warning, error }

void AppSnackBar(
  BuildContext context, {
  required String text,
  SnackBarType type = SnackBarType.success,
}) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

  Color backgroundColor;
  switch (type) {
    case SnackBarType.success:
      backgroundColor = CupertinoColors.activeGreen;
      break;
    case SnackBarType.warning:
      backgroundColor = CupertinoColors.systemYellow;
      break;
    case SnackBarType.error:
      backgroundColor = CupertinoColors.destructiveRed;
      break;
  }

  final snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    duration: UIConstant.snackBarTransitionDuration,
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
  );

  scaffoldMessenger.showSnackBar(snackBar);
}
