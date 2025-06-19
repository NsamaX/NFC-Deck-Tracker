import 'package:nfc_deck_tracker/data/repository/create_record.dart';
import 'package:nfc_deck_tracker/data/repository/delete_record.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_record.dart';
import 'package:nfc_deck_tracker/data/repository/update_record.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/record.dart';
import '../mapper/record.dart';

class FetchRecordUsecase {
  final CreateRecordRepository createRecordRepository;
  final DeleteRecordRepository deleteRecordRepository;
  final FetchRecordRepository fetchRecordRepository;
  final UpdateRecordRepository updateRecordRepository;

  FetchRecordUsecase({
    required this.createRecordRepository,
    required this.deleteRecordRepository,
    required this.fetchRecordRepository,
    required this.updateRecordRepository,
  });

  Future<List<RecordEntity>> call({
    required String userId,
    required String deckId,
  }) async {
    final localModels = await fetchRecordRepository.fetchForLocal(deckId: deckId);
    final localList = localModels.map(RecordMapper.toEntity).toList();
    final localMap = {for (final r in localList) r.recordId: r};

    List<RecordEntity> remoteList = [];
    Map<String, RecordEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final remoteModels = await fetchRecordRepository.fetchForRemote(userId: userId, deckId: deckId);
      remoteList = remoteModels.map(RecordMapper.toEntity).toList();
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
        await createRecordRepository.createForLocal(record: RecordMapper.toModel(remote));
        localList.add(remote);
        LoggerUtil.debugMessage('📥 Imported remote record → local: ${remote.recordId}');
      } else if (remote.updatedAt != null &&
          local.updatedAt != null &&
          remote.updatedAt!.isAfter(local.updatedAt!)) {
        await updateRecordRepository.updateForLocal(record: RecordMapper.toModel(remote));
        final index = localList.indexWhere((r) => r.recordId == remote.recordId);
        if (index != -1) localList[index] = remote;
        LoggerUtil.debugMessage('📥 Updated local record from remote: ${remote.recordId}');
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
        final success = await createRecordRepository.createForRemote(
          userId: userId,
          record: RecordMapper.toModel(local.copyWith(isSynced: true)),
        );

        if (success) {
          final updated = local.copyWith(isSynced: true);
          await updateRecordRepository.updateForLocal(record: RecordMapper.toModel(updated));
          final index = localList.indexWhere((r) => r.recordId == updated.recordId);
          if (index != -1) localList[index] = updated;
          LoggerUtil.debugMessage('📤 Synced local record → remote: ${local.recordId}');
        } else {
          LoggerUtil.debugMessage('⚠️ Failed to sync local → remote: ${local.recordId}');
        }
      }

      else if (remote != null &&
          local.updatedAt != null &&
          remote.updatedAt != null &&
          local.updatedAt!.isAfter(remote.updatedAt!)) {
        final success = await updateRecordRepository.updateForRemote(
          userId: userId,
          record: RecordMapper.toModel(local.copyWith(isSynced: true)),
        );

        if (success) {
          LoggerUtil.debugMessage('🔁 Updated remote with newer local: ${local.recordId}');
        } else {
          LoggerUtil.debugMessage('⚠️ Failed to update newer local → remote: ${local.recordId}');
        }
      }
    }
  }

  Future<void> _removeDeletedRemoteRecords(
    Map<String, RecordEntity> remoteMap,
    List<RecordEntity> localList,
  ) async {
    final toRemove = localList.where(
      (r) => r.isSynced == true && !remoteMap.containsKey(r.recordId),
    ).toList();

    for (final record in toRemove) {
      final success = await deleteRecordRepository.deleteForLocal(recordId: record.recordId);
      if (success) {
        localList.removeWhere((r) => r.recordId == record.recordId);
        LoggerUtil.debugMessage('🗑️ Deleted local record not found in remote: ${record.recordId}');
      } else {
        LoggerUtil.debugMessage('⚠️ Failed to delete local-only record: ${record.recordId}');
      }
    }
  }
}
