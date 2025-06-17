import 'package:nfc_deck_tracker/data/repository/create_record.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
      final remoteSuccess = await createRecordRepository.createRemote(
        userId: userId,
        record: recordModel,
      );

      final syncedRecord = record.copyWith(isSynced: remoteSuccess);
      await createRecordRepository.createLocal(
        record: RecordMapper.toModel(syncedRecord),
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage(message: '⚠️ Remote create failed, saved as local only');
      }
    } else {
      final localOnly = record.copyWith(isSynced: false);
      await createRecordRepository.createLocal(
        record: RecordMapper.toModel(localOnly),
      );
    }
  }
}
