import '../entity/record.dart';
import '../entity/share_record.dart';

abstract interface class RecordRepository {
  Future<void> createForLocal({
    required RecordEntity record,
  });

  Future<bool> createForRemote({
    required String userId,
    required RecordEntity record,
  });

  Future<bool> deleteForLocal({
    required String recordId,
  });

  Future<bool> deleteForRemote({
    required String userId,
    required String recordId,
  });

  Future<List<RecordEntity>> fetchForLocal({
    required String deckId,
  });

  Future<List<RecordEntity>> fetchForRemote({
    required String userId,
    required String deckId,
  });

  Future<ShareRecordEntity> import({
    required String userId,
  });

  Future<bool> share({
    required String userId,
    required ShareRecordEntity shareRecord,
  });

  Future<void> updateForLocal({
    required RecordEntity record,
  });

  Future<bool> updateForRemote({
    required String userId,
    required RecordEntity record,
  });
}
