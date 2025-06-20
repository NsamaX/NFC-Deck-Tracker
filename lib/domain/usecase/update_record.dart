import 'package:nfc_deck_tracker/data/repository/update_record.dart';

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
      final success = await updateRecordRepository.updateForRemote(
        userId: userId,
        record: RecordMapper.toModel(
          updatedRecord.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordModel = RecordMapper.toModel(finalEntity);
    await updateRecordRepository.updateForLocal(record: recordModel);
  }
}
