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

  Future<void> createLocal({
    required RecordModel record,
  }) async {
    await createRecordLocalDatasource.create(record: record);
  }

  Future<bool> createRemote({
    required String userId,
    required RecordModel record,
  }) async {
    return await createRecordRemoteDatasource.create(userId: userId, record: record);
  }
}
