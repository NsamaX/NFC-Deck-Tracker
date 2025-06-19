import 'package:flutter/material.dart';

import '../../theme/@theme.dart';

import '../constant/ui.dart';

enum SnackBarType { success, warning, error }

void AppSnackBar(
  BuildContext context, {
  required String text,
  SnackBarType type = SnackBarType.success,
}) {
  final route = ModalRoute.of(context);
  if (route == null || !route.isCurrent) return;

  final theme = Theme.of(context);
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();

  Color backgroundColor;
  switch (type) {
    case SnackBarType.success:
      backgroundColor = theme.colorScheme.success;
      break;
    case SnackBarType.warning:
      backgroundColor = theme.colorScheme.warning;
      break;
    case SnackBarType.error:
      backgroundColor = theme.colorScheme.error;
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
