import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../locale/localization.dart';

ActionPane? buildSlidableActions({
  required BuildContext context,
  required bool isTrack,
  required CardEntity card,
  required Color? markedColor,
  required Color backgroundColor,
  void Function(Color color)? changeCardColor,
  void Function(String cardId)? onDelete,
}) {
  final theme = Theme.of(context);
  final locale = AppLocalization.of(context);
  final mediaQuery = MediaQuery.of(context);

  if (isTrack && changeCardColor != null) {
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

  if (!isTrack && onDelete != null && card.cardId != null) {
    return ActionPane(
      motion: const StretchMotion(),
      extentRatio: 0.26,
      children: [
        SlidableAction(
          onPressed: (_) => onDelete(card.cardId!),
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.iconTheme.color,
          label: locale.translate('common.button_delete'),
        ),
      ],
    );
  }

  return null;
}
