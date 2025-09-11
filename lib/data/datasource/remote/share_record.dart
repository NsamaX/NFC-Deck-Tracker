import '../../model/share_record.dart';

import '@firestore_service.dart';

class ShareRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  ShareRecordRemoteDatasource(this._firestoreService);

  Future<bool> share({
    required String userId,
    required ShareRecordModel shareRecord,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId',
      documentId: 'room',
      data: shareRecord.toJson(),
    );
  }
}
