import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/create_collection.dart';
import 'package:nfc_deck_tracker/data/repository/delete_collection.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_collection.dart';
import 'package:nfc_deck_tracker/data/repository/update_collection.dart';

import '../entity/collection.dart';
import '../mapper/collection.dart';

class FetchCollectionUsecase {
  final CreateCollectionRepository createCollectionRepository;
  final DeleteCollectionRepository deleteCollectionRepository;
  final FetchCollectionRepository fetchCollectionRepository;
  final UpdateCollectionRepository updateCollectionRepository;

  FetchCollectionUsecase({
    required this.createCollectionRepository,
    required this.deleteCollectionRepository,
    required this.fetchCollectionRepository,
    required this.updateCollectionRepository,
  });

  Future<List<CollectionEntity>> call({
    required String userId,
  }) async {
    final localModels = await fetchCollectionRepository.fetchLocalCollection();
    final localMap = {for (final model in localModels) model.collectionId: model};

    if (userId.isNotEmpty) {
      final remoteModels = await fetchCollectionRepository.fetchRemoteCollection(userId: userId);
      final remoteMap = {
        for (final model in remoteModels) model.collectionId: model,
      };

      for (final remote in remoteModels) {
        final local = localMap[remote.collectionId];
        if (local == null) {
          await createCollectionRepository.createLocalCollection(collection: remote);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await updateCollectionRepository.updateLocalCollection(collection: remote);
        }
      }

      for (final local in localModels) {
        if (local.isSynced == false) {
          final success = await createCollectionRepository.createRemoteCollection(
            userId: userId,
            collection: local,
          );
          if (!success) {
            debugPrint('⚠️ Failed to push local → remote: ${local.collectionId}');
          }
        }
      }

      for (final local in localModels) {
        if (local.isSynced == true && !remoteMap.containsKey(local.collectionId)) {
          final success = await deleteCollectionRepository.deleteLocalCollection(
            collectionId: local.collectionId,
          );
          if (!success) {
            debugPrint('⚠️ Failed to delete local missing from remote: ${local.collectionId}');
          }
        }
      }
    }

    final syncedModels = await fetchCollectionRepository.fetchLocalCollection();
    return syncedModels.map(CollectionMapper.toEntity).toList();
  }
}
