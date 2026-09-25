import '../repository/pending_delete.dart';
import '../service/sync_policy.dart';
import '../value/sync_kind.dart';
import '../repository/record.dart';

class DeleteRecordUsecase {
  final RecordRepository recordRepository;
  final PendingDeleteRepository pendingDeletes;

  DeleteRecordUsecase({
    required this.recordRepository,
    required this.pendingDeletes,
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
      rememberPending: () => pendingDeletes.add(
          userId: userId, kind: SyncKind.record, id: recordId),
    );
  }
}
