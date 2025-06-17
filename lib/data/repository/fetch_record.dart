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

  Future<List<RecordModel>> fetchLocal({
    required String deckId,
  }) async {
    return await fetchRecordLocalDatasource.fetch(deckId: deckId);
  }

  Future<List<RecordModel>> fetchRemote({
    required String userId,
    required String deckId,
  }) async {
    return await fetchRecordRemoteDatasource.fetch(userId: userId, deckId: deckId);
  }
}
