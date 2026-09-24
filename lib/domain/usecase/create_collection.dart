import '../service/clock.dart';
import '../service/id_generator.dart';
import '../service/sync_policy.dart';
import '../repository/collection.dart';

import '../entity/collection.dart';

class CreateCollectionUsecase {
  final CollectionRepository collectionRepository;
  final IdGenerator idGenerator;
  final Clock clock;

  CreateCollectionUsecase({
    required this.collectionRepository,
    this.idGenerator = const IdGenerator(),
    this.clock = const Clock(),
  });

  Future<CollectionEntity> call({
    required String userId,
    required String name,
  }) async {
    final String collectionId = idGenerator.next();

    final newCollection = CollectionEntity(
      collectionId: collectionId,
      name: name,
      updatedAt: clock.now(),
    );

    return const SyncPolicy().write(
      userId: userId,
      entity: newCollection,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) =>
          collectionRepository.createForRemote(userId: userId, collection: e),
      local: (e) => collectionRepository.createForLocal(collection: e),
    );
  }
}
