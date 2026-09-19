import '../repository/collection.dart';

import '../service/domain_logger.dart';

import '../entity/collection.dart';

class FetchCollectionUsecase {
  final DomainLogger logger;
  final CollectionRepository collectionRepository;

  FetchCollectionUsecase({
    this.logger = const SilentDomainLogger(),
    required this.collectionRepository,
  });

  Future<List<CollectionEntity>> call({required String userId}) async {
    final localEntities = await collectionRepository.fetchForLocal();
    final localList = localEntities;
    final localMap = {for (final col in localList) col.collectionId: col};

    List<CollectionEntity> remoteList = [];
    Map<String, CollectionEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final remoteEntities =
          await collectionRepository.fetchForRemote(userId: userId);
      remoteList = remoteEntities;
      remoteMap = {for (final col in remoteList) col.collectionId: col};

      await _importOrUpdateFromRemote(remoteList, localMap, localList);
      await _syncLocalToRemote(userId, localList, remoteMap);
      await _removeLocalIfDeletedFromRemote(remoteMap, localList);
    }

    return localList;
  }

  Future<void> _importOrUpdateFromRemote(
    List<CollectionEntity> remoteList,
    Map<String, CollectionEntity> localMap,
    List<CollectionEntity> localList,
  ) async {
    for (final remote in remoteList) {
      final local = localMap[remote.collectionId];

      if (local == null) {
        await collectionRepository.createForLocal(
          collection: remote,
        );
        localList.add(remote);
        logger.d('Imported remote → local: ${remote.collectionId}');
      } else if (remote.updatedAt != null &&
          local.updatedAt != null &&
          remote.updatedAt!.isAfter(local.updatedAt!)) {
        await collectionRepository.updateForLocal(
          collection: remote,
        );
        final index =
            localList.indexWhere((c) => c.collectionId == remote.collectionId);
        if (index != -1) localList[index] = remote;
        logger.d('Updated local from remote: ${remote.collectionId}');
      } else if (local.name == 'unknow') {
        final updated = local.copyWith(name: remote.name);
        await collectionRepository.updateForLocal(
          collection: updated,
        );
        final index =
            localList.indexWhere((c) => c.collectionId == updated.collectionId);
        if (index != -1) localList[index] = updated;
        logger
            .d('Renamed "unknow" local from remote: ${remote.collectionId}');
      }
    }
  }

  Future<void> _syncLocalToRemote(
    String userId,
    List<CollectionEntity> localList,
    Map<String, CollectionEntity> remoteMap,
  ) async {
    for (final local in localList) {
      final remote = remoteMap[local.collectionId];

      if (local.isSynced != true) {
        final success = await collectionRepository.createForRemote(
          userId: userId,
          collection: local.copyWith(isSynced: true),
        );

        if (success) {
          final updated = local.copyWith(isSynced: true);
          await collectionRepository.updateForLocal(
            collection: updated,
          );
          final index = localList
              .indexWhere((c) => c.collectionId == updated.collectionId);
          if (index != -1) localList[index] = updated;
          logger.d('Synced local → remote: ${local.collectionId}');
        } else {
          logger.e('Failed to sync local → remote: ${local.collectionId}');
        }
      } else if (remote != null &&
          local.updatedAt != null &&
          remote.updatedAt != null &&
          local.updatedAt!.isAfter(remote.updatedAt!)) {
        final success = await collectionRepository.updateForRemote(
          userId: userId,
          collection: local.copyWith(isSynced: true),
        );

        if (success) {
          logger.d('Updated remote with newer local: ${local.collectionId}');
        } else {
          logger.e(
              'Failed to update newer local → remote: ${local.collectionId}');
        }
      }
    }
  }

  Future<void> _removeLocalIfDeletedFromRemote(
    Map<String, CollectionEntity> remoteMap,
    List<CollectionEntity> localList,
  ) async {
    final toRemove = localList
        .where(
          (c) => c.isSynced == true && !remoteMap.containsKey(c.collectionId),
        )
        .toList();

    for (final collection in toRemove) {
      final success = await collectionRepository.deleteForLocal(
        collectionId: collection.collectionId,
      );
      if (success) {
        localList.removeWhere((c) => c.collectionId == collection.collectionId);
        logger.d(
            'Deleted local not found in remote: ${collection.collectionId}');
      } else {
        logger.e(
            'Failed to delete local-only collection: ${collection.collectionId}');
      }
    }
  }
}
