import '../datasource/local/fetch_record.dart';
import '../datasource/remote/fetch_record.dart';
import '../model/record.dart';

class FetchRecordRepository {
  final FetchRecordLocalDatasource fetchRecordLocalDatasource;
  final FetchRecordRemoteDatasource fetchRecordRemoteDatasource;

  FetchRecordRepository({
    required this.fetchRecordLocalDatasource,
    required this.fetchRecordRemoteDatasource,
  });

  Future<List<RecordModel>> fetchLocalRecord({
    required String deckId,
  }) async {
    return await fetchRecordLocalDatasource.fetchRecord(deckId: deckId);
  }

  Future<List<RecordModel>> fetchRemoteRecord({
    required String userId,
    required String deckId,
  }) async {
    return await fetchRecordRemoteDatasource.fetchRecord(userId: userId, deckId: deckId);
  }
}
