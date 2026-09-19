import '../entity/collection.dart';
import '../repository/collection.dart';
import '../service/domain_logger.dart';
import '../service/sync_policy.dart';

class FetchCollectionUsecase {
  final DomainLogger logger;
  final CollectionRepository collectionRepository;

  FetchCollectionUsecase({
    this.logger = const SilentDomainLogger(),
    required this.collectionRepository,
  });

  Future<List<CollectionEntity>> call({required String userId}) async {
    return SyncPolicy(logger: logger).reconcile(
      userId: userId,
      local: await collectionRepository.fetchForLocal(),
      fetchRemote: () => collectionRepository.fetchForRemote(userId: userId),
      target: SyncTarget(
        id: (e) => e.collectionId,
        updatedAt: (e) => e.updatedAt,
        isSynced: (e) => e.isSynced == true,
        markSynced: (e, synced) => e.copyWith(isSynced: synced),
        createLocal: (e) => collectionRepository.createForLocal(collection: e),
        updateLocal: (e) => collectionRepository.updateForLocal(collection: e),
        deleteLocal: (e) =>
            collectionRepository.deleteForLocal(collectionId: e.collectionId),
        createRemote: (e) =>
            collectionRepository.createForRemote(userId: userId, collection: e),
        updateRemote: (e) =>
            collectionRepository.updateForRemote(userId: userId, collection: e),
        mergeExisting: (local, remote) =>
            local.name == 'unknow' ? local.copyWith(name: remote.name) : null,
      ),
    );
  }
}
