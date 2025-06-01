import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ui_constant.dart';

void AppSnackBar(
  BuildContext context, {
  required String text,
  bool isError = false,
}) {
  final snackBar = SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    duration: UIConstant.snackBarTransitionDuration,
    backgroundColor: isError
        ? CupertinoColors.destructiveRed
        : CupertinoColors.activeGreen,
    behavior: SnackBarBehavior.floating,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
