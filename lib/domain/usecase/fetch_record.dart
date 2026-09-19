import '../entity/record.dart';
import '../repository/record.dart';
import '../service/domain_logger.dart';
import '../service/sync_policy.dart';

class FetchRecordUsecase {
  final DomainLogger logger;
  final RecordRepository recordRepository;

  FetchRecordUsecase({
    this.logger = const SilentDomainLogger(),
    required this.recordRepository,
  });

  Future<List<RecordEntity>> call({
    required String userId,
    required String deckId,
  }) async {
    return SyncPolicy(logger: logger).reconcile(
      userId: userId,
      local: await recordRepository.fetchForLocal(deckId: deckId),
      fetchRemote: () =>
          recordRepository.fetchForRemote(userId: userId, deckId: deckId),
      target: SyncTarget(
        id: (e) => e.recordId,
        updatedAt: (e) => e.updatedAt,
        isSynced: (e) => e.isSynced == true,
        markSynced: (e, synced) => e.copyWith(isSynced: synced),
        createLocal: (e) => recordRepository.createForLocal(record: e),
        updateLocal: (e) => recordRepository.updateForLocal(record: e),
        deleteLocal: (e) =>
            recordRepository.deleteForLocal(recordId: e.recordId),
        createRemote: (e) =>
            recordRepository.createForRemote(userId: userId, record: e),
        updateRemote: (e) =>
            recordRepository.updateForRemote(userId: userId, record: e),
      ),
    );
  }
}
