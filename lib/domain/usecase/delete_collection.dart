import '../service/sync_policy.dart';
import '../repository/collection.dart';

class DeleteCollectionUsecase {
  final CollectionRepository collectionRepository;

  DeleteCollectionUsecase({
    required this.collectionRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
  }) async {
    await const SyncPolicy().delete(
      userId: userId,
      local: () =>
          collectionRepository.deleteForLocal(collectionId: collectionId),
      remote: () => collectionRepository.deleteForRemote(
          userId: userId, collectionId: collectionId),
    );
  }
}
