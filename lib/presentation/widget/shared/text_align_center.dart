import 'package:flutter/material.dart';

class TitleAlignCenter extends StatelessWidget {
  final String text;

  const TitleAlignCenter({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        text,
        style: theme.textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
