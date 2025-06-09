import 'package:flutter/material.dart';

import '../constant/ui.dart';

class DescriptionAlignCenter extends StatelessWidget {
  final String text;
  final double bottomSpacing;
  final bool bottomNavHeight;

  const DescriptionAlignCenter({
    super.key,
    required this.text,
    this.bottomSpacing = 0,
    this.bottomNavHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = bottomSpacing + (bottomNavHeight ? kBottomNavigationBarHeight : 0);

    return Padding(
      padding: const EdgeInsets.all(UIConstant.paddingAround),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }
}
