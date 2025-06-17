import '../datasource/local/delete_record.dart';
import '../datasource/remote/delete_record.dart';

class DeleteRecordRepository {
  final DeleteRecordLocalDatasource deleteRecordLocalDatasource;
  final DeleteRecordRemoteDatasource deleteRecordRemoteDatasource;

  DeleteRecordRepository({
    required this.deleteRecordLocalDatasource,
    required this.deleteRecordRemoteDatasource,
  });

  Future<bool> deleteForLocal({
    required String recordId,
  }) async {
    return await deleteRecordLocalDatasource.delete(recordId: recordId);
  }

  Future<bool> deleteForRemote({
    required String userId,
    required String recordId,
  }) async {
    return await deleteRecordRemoteDatasource.delete(userId: userId, recordId: recordId);
  }
}
