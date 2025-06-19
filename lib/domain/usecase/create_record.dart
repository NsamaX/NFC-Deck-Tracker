import 'package:uuid/uuid.dart';

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
    final String recordId = const Uuid().v4();
    final DateTime now = DateTime.now();

    final updatedRecord = record.copyWith(
      recordId: recordId,
      updatedAt: now,
    );

    bool synced = false;

    if (userId.isNotEmpty) {
      final remoteSuccess = await createRecordRepository.createForRemote(
        userId: userId,
        record: RecordMapper.toModel(
          updatedRecord.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage('⚠️ Remote create failed, will fallback to local-only');
      }
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordModel = RecordMapper.toModel(finalEntity);
    await createRecordRepository.createForLocal(record: recordModel);
  }
}
