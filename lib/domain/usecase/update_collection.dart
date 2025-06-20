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
    final DateTime now = DateTime.now();
    final updatedCollection = collection.copyWith(updatedAt: now);

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await updateCollectionRepository.updateForRemote(
        userId: userId,
        collection: CollectionMapper.toModel(
          updatedCollection.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedCollection.copyWith(isSynced: synced);
    final collectionModel = CollectionMapper.toModel(finalEntity);
    await updateCollectionRepository.updateForLocal(collection: collectionModel);
  }
}
