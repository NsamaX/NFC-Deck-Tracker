import '../repository/record.dart';

import '../entity/record.dart';

class UpdateRecordUsecase {
  final RecordRepository recordRepository;

  UpdateRecordUsecase({
    required this.recordRepository,
  });

  Future<void> call({
    required String userId,
    required RecordEntity record,
  }) async {
    final DateTime now = DateTime.now();
    final updatedRecord = record.copyWith(updatedAt: now);

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await recordRepository.updateForRemote(
        userId: userId,
        record: updatedRecord.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordToSave = finalEntity;
    await recordRepository.updateForLocal(record: recordToSave);
  }
}
