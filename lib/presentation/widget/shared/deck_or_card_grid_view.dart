import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../card/item.dart';
import '../deck/item.dart';

class _GridConfig {
  final double spacing;
  final double aspectRatio;

  const _GridConfig({
    required this.spacing, 
    required this.aspectRatio,
  });
}

const _gridConfig = {
  'deck': _GridConfig(spacing: 12.0, aspectRatio: 1.0),
  'card': _GridConfig(spacing: 8.0, aspectRatio: 3 / 4),
};

class DeckOrCardGridView extends StatelessWidget {
  final String userId;
  final List<Object> items;

  const DeckOrCardGridView({
    super.key,
    required this.userId,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    final firstItem = items.first;
    final config = _getGridConfig(item: firstItem);

    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: config.spacing,
        crossAxisSpacing: config.spacing,
        childAspectRatio: config.aspectRatio,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) => _buildItem(context, item: items[index]),
    );
  }

  _GridConfig _getGridConfig({
    required Object item,
  }) {
    if (item is DeckEntity) return _gridConfig['deck']!;
    if (item is CardEntity) return _gridConfig['card']!;
    if (item is MapEntry<CardEntity, int>) return _gridConfig['card']!;

    return const _GridConfig(spacing: 8.0, aspectRatio: 1.0);
  }

  Widget _buildItem(
    BuildContext context, {
    required Object item,
  }) {
    if (item is DeckEntity) return DeckItem(userId: userId, deck: item);
    if (item is CardEntity) return CardItem(card: item);
    if (item is MapEntry<CardEntity, int>) return CardItem(card: item.key, count: item.value);

    return const SizedBox();
  }
}
