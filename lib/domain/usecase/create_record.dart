import 'package:uuid/uuid.dart';

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
    final String recordId = const Uuid().v4();

    final updatedRecord = record.copyWith(
      recordId: recordId,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await createRecordRepository.createForRemote(
        userId: userId,
        record: RecordMapper.toModel(
          updatedRecord.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedRecord.copyWith(isSynced: synced);
    final recordModel = RecordMapper.toModel(finalEntity);
    await createRecordRepository.createForLocal(record: recordModel);
  }
}
