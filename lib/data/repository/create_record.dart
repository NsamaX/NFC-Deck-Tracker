import '../datasource/local/create_record.dart';
import '../datasource/remote/create_record.dart';
import '../model/record.dart';

class CreateRecordRepository {
  final CreateRecordLocalDatasource createRecordLocalDatasource;
  final CreateRecordRemoteDatasource createRecordRemoteDatasource;

  CreateRecordRepository({
    required this.createRecordLocalDatasource,
    required this.createRecordRemoteDatasource,
  });

  Future<void> createLocalRecord({
    required RecordModel record,
  }) async {
    await createRecordLocalDatasource.createRecord(record: record);
  }

  Future<bool> createRemoteRecord({
    required String userId,
    required RecordModel record,
  }) async {
    return await createRecordRemoteDatasource.createRecord(userId: userId, record: record);
  }
}
