import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/create_record.dart';
import 'package:nfc_deck_tracker/data/repository/delete_record.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_record.dart';
import 'package:nfc_deck_tracker/data/repository/update_record.dart';

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
    final localRecords = await fetchRecordRepository.fetchLocalRecord(deckId: deckId);
    final localMap = {for (final r in localRecords) r.recordId: r};

    if (userId.isNotEmpty) {
      final remoteRecords = await fetchRecordRepository.fetchRemoteRecord(
        userId: userId,
        deckId: deckId,
      );
      final remoteMap = {for (final r in remoteRecords) r.recordId: r};

      for (final remote in remoteRecords) {
        final local = localMap[remote.recordId];
        if (local == null) {
          await createRecordRepository.createLocalRecord(record: remote);
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await updateRecordRepository.updateLocalRecord(record: remote);
        }
      }

      for (final local in localRecords) {
        if (local.isSynced == false) {
          final success = await createRecordRepository.createRemoteRecord(
            userId: userId,
            record: local,
          );
          if (!success) {
            debugPrint('⚠️ Failed to sync local → remote: ${local.recordId}');
          }
        }
      }

      for (final local in localRecords) {
        if (local.isSynced == true && !remoteMap.containsKey(local.recordId)) {
          final success = await deleteRecordRepository.deleteLocalRecord(
            recordId: local.recordId,
          );
          if (!success) {
            debugPrint('⚠️ Failed to delete local record not in remote: ${local.recordId}');
          }
        }
      }
    }

    final syncedRecords = await fetchRecordRepository.fetchLocalRecord(deckId: deckId);
    return syncedRecords.map(RecordMapper.toEntity).toList();
  }
}
