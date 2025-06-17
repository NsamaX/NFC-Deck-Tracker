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

  Future<void> updateForLocal({
    required RecordModel record,
  }) async {
    await updateRecordLocalDatasource.update(record: record);
  }

  Future<bool> updateForRemote({
    required String userId,
    required RecordModel record,
  }) async {
    return await updateRecordRemoteDatasource.update(userId: userId, record: record);
  }
}
