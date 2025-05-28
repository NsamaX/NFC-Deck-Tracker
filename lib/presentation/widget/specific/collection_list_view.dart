import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/data/datasource/api/_api_config.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import '../material/collection.dart';

class CollectionListViewWidget extends StatelessWidget {
  final List<CollectionEntity> collections;
  final List<String> gameKeys;
  final List<String> gameImages;
  final bool isAdd;

  const CollectionListViewWidget({
    super.key,
    required this.collections,
    required this.gameKeys,
    required this.gameImages,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty && gameKeys.isEmpty) return const SizedBox.shrink();

    final userCollections = collections
        .where((e) => !GameConstant.isSupported(e.collectionId))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView(
        children: [
          ...userCollections.map((collection) => _buildUserItem(context, collection)),
          if (gameKeys.isNotEmpty)
            ListView.builder(
              itemCount: gameKeys.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) => _buildGameItem(context, index),
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, CollectionEntity collection) {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm')
        .format(collection.updatedAt ?? DateTime.now());

    return CollectionWidget(
      collectionId: collection.collectionId,
      collectionName: collection.name,
      description: formattedDate,
      isAdd: isAdd,
    );
  }

  Widget _buildGameItem(BuildContext context, int index) {
    return CollectionWidget(
      collectionId: gameKeys[index],
      collectionName: gameKeys[index],
      description: ApiConfig.getBaseUrl(gameKeys[index]),
      imagePath: gameImages[index],
      isAdd: isAdd,
    );
  }
}
