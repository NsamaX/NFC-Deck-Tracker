import '../repository/pending_delete.dart';
import '../service/sync_policy.dart';
import '../value/sync_kind.dart';
import '../repository/collection.dart';

class DeleteCollectionUsecase {
  final CollectionRepository collectionRepository;
  final PendingDeleteRepository pendingDeletes;

  DeleteCollectionUsecase({
    required this.collectionRepository,
    required this.pendingDeletes,
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
      rememberPending: () => pendingDeletes.add(
          userId: userId, kind: SyncKind.collection, id: collectionId),
    );
  }
}
