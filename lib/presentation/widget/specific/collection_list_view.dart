import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/data/datasource/api/_api_config.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import '../../cubit/collection_cubit.dart';

import '../material/collection.dart';

class CollectionListView extends StatelessWidget {
  final List<String> gameKeys;
  final List<String> gameImages;
  final bool onAdd;

  const CollectionListView({
    super.key,
    required this.gameKeys,
    required this.gameImages,
    this.onAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    if (context.read<CollectionCubit>().state.collections.isEmpty && gameKeys.isEmpty) return const SizedBox.shrink();

    final userCollections = context.read<CollectionCubit>().state.collections
        .where((e) => !GameConstant.isSupported(e.collectionId))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ListView(
        children: [
          ...userCollections.map((collection) => _buildUserItem(collection)),
          if (gameKeys.isNotEmpty)
            ListView.builder(
              itemCount: gameKeys.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, index) => _buildGameItem(index),
            ),
        ],
      ),
    );
  }

  Widget _buildUserItem(CollectionEntity collection) {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(collection.updatedAt!);

    return CollectionWidget(
      collectionId: collection.collectionId,
      collectionName: collection.name,
      description: formattedDate,
      onAdd: onAdd,
    );
  }

  Widget _buildGameItem(int index) {
    return CollectionWidget(
      collectionId: gameKeys[index],
      collectionName: gameKeys[index],
      description: ApiConfig.getBaseUrl(gameKeys[index]),
      imagePath: gameImages[index],
      onAdd: onAdd,
    );
  }
}
