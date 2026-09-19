import '../service/sync_policy.dart';
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

    await const SyncPolicy().write(
      userId: userId,
      entity: updatedRecord,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) =>
          recordRepository.updateForRemote(userId: userId, record: e),
      local: (e) => recordRepository.updateForLocal(record: e),
    );
  }
}
