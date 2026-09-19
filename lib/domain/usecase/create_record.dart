import 'package:uuid/uuid.dart';

import '../repository/record.dart';

import '../entity/record.dart';

class CreateRecordUsecase {
  final RecordRepository recordRepository;

  CreateRecordUsecase({
    required this.recordRepository,
  });

  Future<void> call({
    required String userId,
    required RecordEntity record,
  }) async {
    final String recordId = const Uuid().v4();

    final updatedRecord = record.copyWith(
      recordId: recordId,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await recordRepository.createForRemote(
        userId: userId,
        record: updatedRecord.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordToSave = finalEntity;
    await recordRepository.createForLocal(record: recordToSave);
  }
}
