import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

ActionPane? buildCardSlidablePinColor({
  required BuildContext context,
  required Color? markedColor,
  required Color backgroundColor,
  required void Function(Color color) changeCardColor,
}) {
  final theme = Theme.of(context);
  final mediaQuery = MediaQuery.of(context);

  final allColors = [
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
    theme.colorScheme.tertiary,
  ];

  final colors = markedColor != null && allColors.contains(markedColor)
      ? [markedColor, ...allColors.where((c) => c != markedColor)]
      : allColors;

  return ActionPane(
    motion: const StretchMotion(),
    extentRatio: (60.0 * colors.length) / mediaQuery.size.width,
    children: colors.map((color) {
      final isSelected = markedColor == color;
      return SlidableAction(
        onPressed: (_) {
          final newColor = isSelected ? backgroundColor : color;
          changeCardColor(newColor);
        },
        backgroundColor: color,
        foregroundColor: theme.appBarTheme.backgroundColor,
        icon: isSelected ? Icons.close_rounded : Icons.push_pin_rounded,
      );
    }).toList(),
  );
}
