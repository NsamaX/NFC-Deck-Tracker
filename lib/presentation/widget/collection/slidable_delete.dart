import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import '../../locale/localization.dart';

ActionPane? buildCollectionSlidableDelete({
  required BuildContext context,
  required CollectionEntity collection,
  required void Function(String cardId) onDelete,
}) {
  final theme = Theme.of(context);
  final locale = AppLocalization.of(context);

  return ActionPane(
    motion: const StretchMotion(),
    extentRatio: 0.26,
    children: [
      SlidableAction(
        onPressed: (_) => onDelete(collection.collectionId),
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.iconTheme.color,
        label: locale.translate('common.button_delete'),
      ),
    ],
  );
}
 