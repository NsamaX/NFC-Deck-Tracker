import 'package:flutter/material.dart';

class ButtonMaxWidth extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonMaxWidth({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 46.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.scaffoldBackgroundColor,
          ),
        ),
      ),
    );
  }
}
