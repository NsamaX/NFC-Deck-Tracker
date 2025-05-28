import '../datasource/local/delete_record.dart';
import '../datasource/remote/delete_record.dart';

class DeleteRecordRepository {
  final DeleteRecordLocalDatasource deleteRecordLocalDatasource;
  final DeleteRecordRemoteDatasource deleteRecordRemoteDatasource;

  DeleteRecordRepository({
    required this.deleteRecordLocalDatasource,
    required this.deleteRecordRemoteDatasource,
  });

  Future<bool> deleteLocalRecord({
    required String recordId,
  }) async {
    return await deleteRecordLocalDatasource.deleteRecord(recordId: recordId);
  }

  Future<bool> deleteRemoteRecord({
    required String userId,
    required String recordId,
  }) async {
    return await deleteRecordRemoteDatasource.deleteRecord(userId: userId, recordId: recordId);
  }
}
