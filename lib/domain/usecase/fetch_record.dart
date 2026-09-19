import '../repository/record.dart';

import '../service/domain_logger.dart';

import '../entity/record.dart';

class FetchRecordUsecase {
  final DomainLogger logger;
  final RecordRepository recordRepository;

  FetchRecordUsecase({
    this.logger = const SilentDomainLogger(),
    required this.recordRepository,
  });

  Future<List<RecordEntity>> call({
    required String userId,
    required String deckId,
  }) async {
    final localEntities = await recordRepository.fetchForLocal(deckId: deckId);
    final localList = localEntities;
    final localMap = {for (final r in localList) r.recordId: r};

    List<RecordEntity> remoteList = [];
    Map<String, RecordEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final remoteEntities =
          await recordRepository.fetchForRemote(userId: userId, deckId: deckId);
      remoteList = remoteEntities;
      remoteMap = {for (final r in remoteList) r.recordId: r};

      await _importOrUpdateFromRemote(remoteList, localMap, localList);
      await _syncLocalToRemote(userId, localList, remoteMap);
      await _removeDeletedRemoteRecords(remoteMap, localList);
    }

    return localList;
  }

  Future<void> _importOrUpdateFromRemote(
    List<RecordEntity> remoteList,
    Map<String, RecordEntity> localMap,
    List<RecordEntity> localList,
  ) async {
    for (final remote in remoteList) {
      final local = localMap[remote.recordId];

      if (local == null) {
        await recordRepository.createForLocal(record: remote);
        localList.add(remote);
        logger.d('Imported remote record → local: ${remote.recordId}');
      } else if (remote.updatedAt != null &&
          local.updatedAt != null &&
          remote.updatedAt!.isAfter(local.updatedAt!)) {
        await recordRepository.updateForLocal(record: remote);
        final index =
            localList.indexWhere((r) => r.recordId == remote.recordId);
        if (index != -1) localList[index] = remote;
        logger.d('Updated local record from remote: ${remote.recordId}');
      }
    }
  }

  Future<void> _syncLocalToRemote(
    String userId,
    List<RecordEntity> localList,
    Map<String, RecordEntity> remoteMap,
  ) async {
    for (final local in localList) {
      final remote = remoteMap[local.recordId];

      if (local.isSynced != true) {
        final success = await recordRepository.createForRemote(
          userId: userId,
          record: local.copyWith(isSynced: true),
        );

        if (success) {
          final updated = local.copyWith(isSynced: true);
          await recordRepository.updateForLocal(record: updated);
          final index =
              localList.indexWhere((r) => r.recordId == updated.recordId);
          if (index != -1) localList[index] = updated;
          logger.d('Synced local record → remote: ${local.recordId}');
        } else {
          logger.e('Failed to sync local → remote: ${local.recordId}');
        }
      } else if (remote != null &&
          local.updatedAt != null &&
          remote.updatedAt != null &&
          local.updatedAt!.isAfter(remote.updatedAt!)) {
        final success = await recordRepository.updateForRemote(
          userId: userId,
          record: local.copyWith(isSynced: true),
        );

        if (success) {
          logger.d('Updated remote with newer local: ${local.recordId}');
        } else {
          logger
              .e('Failed to update newer local → remote: ${local.recordId}');
        }
      }
    }
  }

  Future<void> _removeDeletedRemoteRecords(
    Map<String, RecordEntity> remoteMap,
    List<RecordEntity> localList,
  ) async {
    final toRemove = localList
        .where(
          (r) => r.isSynced == true && !remoteMap.containsKey(r.recordId),
        )
        .toList();

    for (final record in toRemove) {
      final success =
          await recordRepository.deleteForLocal(recordId: record.recordId);
      if (success) {
        localList.removeWhere((r) => r.recordId == record.recordId);
        logger.d(
            'Deleted local record not found in remote: ${record.recordId}');
      } else {
        logger.e('Failed to delete local-only record: ${record.recordId}');
      }
    }
  }
}
