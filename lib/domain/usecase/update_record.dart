import 'package:nfc_deck_tracker/data/repository/update_record.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/record.dart';
import '../mapper/record.dart';

class UpdateRecordUsecase {
  final UpdateRecordRepository updateRecordRepository;

  UpdateRecordUsecase({
    required this.updateRecordRepository,
  });

  Future<void> call({
    required String userId,
    required RecordEntity record,
  }) async {
    final recordModel = RecordMapper.toModel(record);

    if (userId.isNotEmpty) {
      final success = await updateRecordRepository.updateRemote(
        userId: userId,
        record: recordModel,
      );

      final syncedRecord = record.copyWith(isSynced: success);
      await updateRecordRepository.updateLocal(
        record: RecordMapper.toModel(syncedRecord),
      );

      if (!success) {
        LoggerUtil.debugMessage(message: '⚠️ Remote update failed, saved as local only');
      }
    } else {
      final localOnly = record.copyWith(isSynced: false);
      await updateRecordRepository.updateLocal(
        record: RecordMapper.toModel(localOnly),
      );
    }
  }
}
