import '../datasource/remote/share_record.dart';
import '../model/share_record.dart';

class ShareRecordRepository {
  final ShareRecordRemoteDatasource shareRecordRemoteDatasource;

  ShareRecordRepository({
    required this.shareRecordRemoteDatasource,
  });

  Future<bool> share({
    required String userId,
    required ShareRecordModel shareRecord,
  }) async {
    return await shareRecordRemoteDatasource.share(userId: userId, shareRecord: shareRecord);
  }
}
