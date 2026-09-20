import 'package:uuid/uuid.dart';

import '../service/sync_policy.dart';
import '../repository/collection.dart';

import '../entity/collection.dart';

class CreateCollectionUsecase {
  final CollectionRepository collectionRepository;

  CreateCollectionUsecase({
    required this.collectionRepository,
  });

  Future<CollectionEntity> call({
    required String userId,
    required String name,
  }) async {
    final String collectionId = const Uuid().v4();

    final newCollection = CollectionEntity(
      collectionId: collectionId,
      name: name,
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
