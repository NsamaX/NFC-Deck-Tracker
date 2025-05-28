import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/create_record.dart';

import '../entity/record.dart';
import '../mapper/record.dart';

class CreateRecordUsecase {
  final CreateRecordRepository createRecordRepository;

  CreateRecordUsecase({
    required this.createRecordRepository,
  });

  Future<void> call({
    required String userId,
    required RecordEntity record,
  }) async {
    final recordModel = RecordMapper.toModel(record);

    if (userId.isNotEmpty) {
      final remoteSuccess = await createRecordRepository.createRemoteRecord(
        userId: userId,
        record: recordModel,
      );

      final syncedRecord = record.copyWith(isSynced: remoteSuccess);
      await createRecordRepository.createLocalRecord(
        record: RecordMapper.toModel(syncedRecord),
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote create failed, saved as local only');
      }
    } else {
      final localOnly = record.copyWith(isSynced: false);
      await createRecordRepository.createLocalRecord(
        record: RecordMapper.toModel(localOnly),
      );
    }
  }
}
