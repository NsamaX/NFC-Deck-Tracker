import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.config/setting.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@api_config.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import '../../cubit/application_cubit.dart';
import '../../cubit/collection_cubit.dart';

import 'item.dart';
import 'slidable_delete.dart';

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

    return Builder(
      builder: (context) => Slidable(
        key: ValueKey(collection.collectionId),
        endActionPane: buildCollectionSlidableDelete(
          context: context,
          collection: collection,
          onDelete: (collectionId) {
            context.read<CollectionCubit>().deleteCollection(
              userId: userId,
              collectionId: collectionId,
            );
            if (collectionId == context.read<ApplicationCubit>().state.recentId) {
              context.read<ApplicationCubit>().updateSettingUsecase(key: Setting.keyRecentId, value: '');
            }
          },
        ),
        child: CollectionItem(
          collectionId: collection.collectionId,
          collectionName: collection.name,
          description: formattedDate,
          onAdd: onAdd,
        ),
      ),
    );
  }

  Widget _buildGameItem(int index) {
    return CollectionItem(
      collectionId: gameKeys[index],
      collectionName: gameKeys[index],
      description: ApiConfig.getBaseUrl(gameKeys[index]),
      imagePath: gameImages[index],
      onAdd: onAdd,
    );
  }
}
