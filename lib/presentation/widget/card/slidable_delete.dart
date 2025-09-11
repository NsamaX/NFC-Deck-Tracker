import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../locale/localization.dart';

ActionPane? buildCardSlidableDelete({
  required BuildContext context,
  required CardEntity card,
  required void Function(String cardId) onDelete,
}) {
  final theme = Theme.of(context);
  final locale = AppLocalization.of(context);

  if (card.cardId == null) return null;

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
