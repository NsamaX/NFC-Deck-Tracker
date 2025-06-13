import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/@theme.dart';

class DialogChoice {
  final String text;
  final bool isCancel;
  final VoidCallback onPressed;

  DialogChoice({
    required this.text,
    this.isCancel = false,
    required this.onPressed,
  });
}

void buildCupertinoAlertDialog({
  required ThemeData theme,
  required String title,
  required String content,
  required String confirmButtonText,
  required VoidCallback? onPressed,
  required VoidCallback closeDialog,
  required void Function(Widget dialog) showDialog,
}) {
  _buildShowDialog(
    theme: theme,
    title: title,
    content: content,
    actions: [
      _buildActionDialog(
        text: confirmButtonText,
        color: theme.colorScheme.active,
        onPressed: () {
          closeDialog();
          onPressed?.call();
        },
      ),
    ],
    showDialog: showDialog,
  );
}

void buildCupertinoActionDialog({
  required ThemeData theme,
  required String title,
  required String content,
  required String cancelButtonText,
  required String confirmButtonText,
  required VoidCallback onPressed,
  required VoidCallback closeDialog,
  required void Function(Widget dialog) showDialog,
}) {
  _buildShowDialog(
    theme: theme,
    title: title,
    content: content,
    actions: [
      _buildActionDialog(
        text: cancelButtonText,
        color: theme.colorScheme.error,
        onPressed: closeDialog,
      ),
      _buildActionDialog(
        text: confirmButtonText,
        color: theme.colorScheme.active,
        onPressed: () {
          closeDialog();
          onPressed();
        },
      ),
    ],
    showDialog: showDialog,
  );
}

void buildCupertinoMultipleChoicesDialog({
  required ThemeData theme,
  required String title,
  required String content,
  required List<DialogChoice> choices,
  required void Function(Widget dialog) showDialog,
}) {
  _buildShowDialog(
    theme: theme,
    title: title,
    content: content,
    actions: choices.map((choice) {
      return _buildActionDialog(
        text: choice.text,
        color: choice.isCancel
            ? theme.colorScheme.error
            : theme.colorScheme.active,
        onPressed: choice.onPressed,
      );
    }).toList(),
    showDialog: showDialog,
  );
}

void buildCupertinoTextFieldDialog({
  required ThemeData theme,
  required String title,
  required String cancelButtonText,
  required String confirmButtonText,
  required void Function(String value) onConfirm,
  required VoidCallback closeDialog,
  required void Function(Widget dialog) showDialog,
}) {
  final TextEditingController controller = TextEditingController();

  showDialog(
    CupertinoAlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 22.0),
          CupertinoTextField(
            controller: controller,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: closeDialog,
          child: Text(
            cancelButtonText,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12.0,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            closeDialog();
            onConfirm(controller.text);
          },
          child: Text(
            confirmButtonText,
            style: TextStyle(
              color: theme.colorScheme.active,
              fontSize: 12.0,
              fontWeight: FontWeight.w100,
            ),
          ),
        ),
      ],
    ),
  );
}

void _buildShowDialog({
  required ThemeData theme,
  required String title,
  required String content,
  required List<Widget> actions,
  required void Function(Widget dialog) showDialog,
}) {
  final dialog = CupertinoAlertDialog(
    title: _buildTitleDialog(theme: theme, text: title),
    content: _buildContentDialog(theme: theme, text: content),
    actions: actions,
  );
  showDialog(dialog);
}

Widget _buildTitleDialog({
  required ThemeData theme,
  required String text,
}) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.black,
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _buildContentDialog({
  required ThemeData theme,
  required String text,
}) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.black,
      fontSize: 12.0,
      fontWeight: FontWeight.w100,
    ),
  );
}

Widget _buildActionDialog({
  required String text,
  required Color color,
  required VoidCallback onPressed,
}) {
  return CupertinoDialogAction(
    onPressed: onPressed,
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12.0,
        fontWeight: FontWeight.w100,
      ),
    ),
  );
}
