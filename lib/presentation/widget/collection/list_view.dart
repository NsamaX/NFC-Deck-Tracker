import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import 'custom_game_tile.dart';
import 'supported_game_tile.dart';

class CollectionListView extends StatelessWidget {
  final List<String> gameKeys;
  final List<String> gameImages;
  final List<CollectionEntity> collections;
  final String userId;
  final bool onAdd;

  const CollectionListView({
    super.key,
    required this.gameKeys,
    required this.gameImages,
    required this.collections,
    required this.userId,
    this.onAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty && gameKeys.isEmpty) return const SizedBox.shrink();

    final userCollections = collections.where((e) => !Game.isSupported(e.collectionId)).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView(
        children: [
          ...userCollections.map((collection) => CustomGameTile(
                collection: collection,
                userId: userId,
                onAdd: onAdd,
              )),
          if (gameKeys.isNotEmpty)
            ListView.builder(
              itemCount: gameKeys.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) => SupportedGameTile(
                gameKey: gameKeys[index],
                gameImage: gameImages[index],
                onAdd: onAdd,
              ),
            ),
        ],
      ),
    );
  }
}
