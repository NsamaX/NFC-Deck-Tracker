import '../service/clock.dart';
import '../service/id_generator.dart';
import '../service/sync_policy.dart';
import '../repository/record.dart';

import '../entity/record.dart';

class CreateRecordUsecase {
  final RecordRepository recordRepository;
  final IdGenerator idGenerator;
  final Clock clock;

  CreateRecordUsecase({
    required this.recordRepository,
    this.idGenerator = const IdGenerator(),
    this.clock = const Clock(),
  });

  Future<RecordEntity> call({
    required String userId,
    required RecordEntity record,
  }) async {
    final now = clock.now();
    final updatedRecord = record.copyWith(
      recordId: record.recordId.isEmpty ? idGenerator.next() : record.recordId,
      createdAt: record.createdAt ?? now,
      updatedAt: now,
    );

    return const SyncPolicy().write(
      userId: userId,
      entity: updatedRecord,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) =>
          recordRepository.createForRemote(userId: userId, record: e),
      local: (e) => recordRepository.createForLocal(record: e),
    );
  }
}
