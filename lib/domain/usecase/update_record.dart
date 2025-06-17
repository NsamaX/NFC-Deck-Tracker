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
    final DateTime now = DateTime.now();
    final updatedRecord = record.copyWith(updatedAt: now);

    bool synced = false;
    if (userId.isNotEmpty) {
      final remoteSuccess = await updateRecordRepository.updateForRemote(
        userId: userId,
        record: RecordMapper.toModel(
          updatedRecord.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage(message: '⚠️ Remote update failed, will fallback to local-only');
      }
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordModel = RecordMapper.toModel(finalEntity);
    await updateRecordRepository.updateForLocal(record: recordModel);
  }
}
