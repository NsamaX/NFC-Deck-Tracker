import '../service/clock.dart';
import '../service/sync_policy.dart';
import '../repository/collection.dart';

import '../entity/collection.dart';

class UpdateCollectionUsecase {
  final CollectionRepository collectionRepository;
  final Clock clock;

  UpdateCollectionUsecase({
    required this.collectionRepository,
    this.clock = const Clock(),
  });

  Future<void> call({
    required String userId,
    required CollectionEntity collection,
  }) async {
    final DateTime now = clock.now();
    final updatedCollection = collection.copyWith(updatedAt: now);

    await const SyncPolicy().write(
      userId: userId,
      entity: updatedCollection,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) =>
          collectionRepository.updateForRemote(userId: userId, collection: e),
      local: (e) => collectionRepository.updateForLocal(collection: e),
    );
  }
}
