import 'package:nfc_deck_tracker/data/repository/create_collection.dart';
import 'package:nfc_deck_tracker/data/repository/delete_collection.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_collection.dart';
import 'package:nfc_deck_tracker/data/repository/update_collection.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/collection.dart';
import '../mapper/collection.dart';

class FetchCollectionUsecase {
  final CreateCollectionRepository createCollectionRepository;
  final DeleteCollectionRepository deleteCollectionRepository;
  final FetchCollectionRepository fetchCollectionRepository;
  final UpdateCollectionRepository updateCollectionRepository;

  FetchCollectionUsecase({
    required this.createCollectionRepository,
    required this.deleteCollectionRepository,
    required this.fetchCollectionRepository,
    required this.updateCollectionRepository,
  });

  Future<List<CollectionEntity>> call({required String userId}) async {
    final localModels = await fetchCollectionRepository.fetchForLocal();
    final localList = localModels.map(CollectionMapper.toEntity).toList();
    final localMap = {for (final col in localList) col.collectionId: col};

    List<CollectionEntity> remoteList = [];
    Map<String, CollectionEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final remoteModels = await fetchCollectionRepository.fetchForRemote(userId: userId);
      remoteList = remoteModels.map(CollectionMapper.toEntity).toList();
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
        await createCollectionRepository.createForLocal(
          collection: CollectionMapper.toModel(remote),
        );
        localList.add(remote);
        LoggerUtil.debugMessage(message: '📥 Imported remote → local: ${remote.collectionId}');
      } else if (remote.updatedAt != null &&
          local.updatedAt != null &&
          remote.updatedAt!.isAfter(local.updatedAt!)) {
        await updateCollectionRepository.updateForLocal(
          collection: CollectionMapper.toModel(remote),
        );
        final index = localList.indexWhere((c) => c.collectionId == remote.collectionId);
        if (index != -1) localList[index] = remote;
        LoggerUtil.debugMessage(message: '📥 Updated local from remote: ${remote.collectionId}');
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
        final success = await createCollectionRepository.createForRemote(
          userId: userId,
          collection: CollectionMapper.toModel(local.copyWith(isSynced: true)),
        );

        if (success) {
          final updated = local.copyWith(isSynced: true);
          await updateCollectionRepository.updateForLocal(
            collection: CollectionMapper.toModel(updated),
          );
          final index = localList.indexWhere((c) => c.collectionId == updated.collectionId);
          if (index != -1) localList[index] = updated;
          LoggerUtil.debugMessage(message: '📤 Synced local → remote: ${local.collectionId}');
        } else {
          LoggerUtil.debugMessage(message: '⚠️ Failed to sync local → remote: ${local.collectionId}');
        }

      } else if (remote != null &&
          local.updatedAt != null &&
          remote.updatedAt != null &&
          local.updatedAt!.isAfter(remote.updatedAt!)) {
        final success = await updateCollectionRepository.updateForRemote(
          userId: userId,
          collection: CollectionMapper.toModel(local.copyWith(isSynced: true)),
        );

        if (success) {
          LoggerUtil.debugMessage(message: '🔁 Updated remote with newer local: ${local.collectionId}');
        } else {
          LoggerUtil.debugMessage(message: '⚠️ Failed to update newer local → remote: ${local.collectionId}');
        }
      }
    }
  }

  Future<void> _removeLocalIfDeletedFromRemote(
    Map<String, CollectionEntity> remoteMap,
    List<CollectionEntity> localList,
  ) async {
    final toRemove = localList.where(
      (c) => c.isSynced == true && !remoteMap.containsKey(c.collectionId),
    ).toList();

    for (final collection in toRemove) {
      final success = await deleteCollectionRepository.deleteForLocal(
        collectionId: collection.collectionId,
      );
      if (success) {
        localList.removeWhere((c) => c.collectionId == collection.collectionId);
        LoggerUtil.debugMessage(message: '🗑️ Deleted local not found in remote: ${collection.collectionId}');
      } else {
        LoggerUtil.debugMessage(message: '⚠️ Failed to delete local-only collection: ${collection.collectionId}');
      }
    }
  }
}
