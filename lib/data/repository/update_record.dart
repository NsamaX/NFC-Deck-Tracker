import '../datasource/local/update_record.dart';
import '../datasource/remote/update_record.dart';
import '../model/record.dart';

class UpdateRecordRepository {
  final UpdateRecordLocalDatasource updateRecordLocalDatasource;
  final UpdateRecordRemoteDatasource updateRecordRemoteDatasource;

  UpdateRecordRepository({
    required this.updateRecordLocalDatasource,
    required this.updateRecordRemoteDatasource,
  });

  Future<void> updateLocalRecord({
    required RecordModel record,
  }) async {
    await updateRecordLocalDatasource.updateRecord(record: record);
  }

  Future<bool> updateRemoteRecord({
    required String userId,
    required RecordModel record,
  }) async {
    return await updateRecordRemoteDatasource.updateRecord(userId: userId, record: record);
  }
}
