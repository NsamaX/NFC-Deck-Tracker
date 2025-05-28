import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/update_collection.dart';

import '../entity/collection.dart';
import '../mapper/collection.dart';

class UpdateCollectionUsecase {
  final UpdateCollectionRepository updateCollectionRepository;

  UpdateCollectionUsecase({
    required this.updateCollectionRepository,
  });

  Future<void> call({
    required String userId,
    required CollectionEntity collection,
  }) async {
    final collectionModel = CollectionMapper.toModel(collection);

    if (userId.isNotEmpty) {
      final success = await updateCollectionRepository.updateRemoteCollection(
        userId: userId,
        collection: collectionModel,
      );

      final syncedCollection = collection.copyWith(isSynced: success);
      await updateCollectionRepository.updateLocalCollection(
        collection: CollectionMapper.toModel(syncedCollection),
      );

      if (!success) {
        debugPrint('⚠️ Remote update failed, saved as local only');
      }
    } else {
      final localOnly = collection.copyWith(isSynced: false);
      await updateCollectionRepository.updateLocalCollection(
        collection: CollectionMapper.toModel(localOnly),
      );
    }
  }
}
