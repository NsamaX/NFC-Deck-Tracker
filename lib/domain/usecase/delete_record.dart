import '../service/sync_policy.dart';
import '../repository/record.dart';

class DeleteRecordUsecase {
  final RecordRepository recordRepository;

  DeleteRecordUsecase({
    required this.recordRepository,
  });

  Future<void> call({
    required String userId,
    required String recordId,
  }) async {
    await const SyncPolicy().delete(
      userId: userId,
      local: () => recordRepository.deleteForLocal(recordId: recordId),
      remote: () =>
          recordRepository.deleteForRemote(userId: userId, recordId: recordId),
    );
  }
}
