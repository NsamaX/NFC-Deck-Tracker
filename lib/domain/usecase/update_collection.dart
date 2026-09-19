import '../repository/collection.dart';

import '../entity/collection.dart';

class UpdateCollectionUsecase {
  final CollectionRepository collectionRepository;

  UpdateCollectionUsecase({
    required this.collectionRepository,
  });

  Future<void> call({
    required String userId,
    required CollectionEntity collection,
  }) async {
    final DateTime now = DateTime.now();
    final updatedCollection = collection.copyWith(updatedAt: now);

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await collectionRepository.updateForRemote(
        userId: userId,
        collection: updatedCollection.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedCollection.copyWith(isSynced: synced);
    final collectionToSave = finalEntity;
    await collectionRepository.updateForLocal(collection: collectionToSave);
  }
}
