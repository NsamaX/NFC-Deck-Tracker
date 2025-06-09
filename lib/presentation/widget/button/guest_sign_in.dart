import 'package:flutter/material.dart';

import '../../../util/google_athen.dart';

class ButtonGuestSignIn extends StatelessWidget {
  final String text;

  const ButtonGuestSignIn({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 46.0,
      child: ElevatedButton(
        onPressed: () => handleGuestSignIn(context),
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
