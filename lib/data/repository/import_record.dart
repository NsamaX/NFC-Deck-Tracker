import '../datasource/remote/import_record.dart';
import '../model/share_record.dart';

class ImportRecordRepository {
  final ImportRecordRemoteDatasource importRecordRemoteDatasource;

  ImportRecordRepository({
    required this.importRecordRemoteDatasource,
  });

  Future<ShareRecordModel> import({
    required String userId,
  }) async {
    final shareRecord = await importRecordRemoteDatasource.import(userId: userId);
    return shareRecord!;
  }
}
