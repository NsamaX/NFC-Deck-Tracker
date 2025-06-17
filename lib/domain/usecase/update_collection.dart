import 'package:nfc_deck_tracker/data/repository/update_collection.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
      final success = await updateCollectionRepository.updateForRemote(
        userId: userId,
        collection: collectionModel,
      );

      final syncedCollection = collection.copyWith(isSynced: success);
      await updateCollectionRepository.updateForLocal(
        collection: CollectionMapper.toModel(syncedCollection),
      );

      if (!success) {
        LoggerUtil.debugMessage(message: '⚠️ Remote update failed, saved as local only');
      }
    } else {
      final localOnly = collection.copyWith(isSynced: false);
      await updateCollectionRepository.updateForLocal(
        collection: CollectionMapper.toModel(localOnly),
      );
    }
  }
}
