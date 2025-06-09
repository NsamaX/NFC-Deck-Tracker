import '@firestore_service.dart';

import '../../model/record.dart';

class UpdateRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateRecordRemoteDatasource(this._firestoreService);

  Future<bool> updateRecord({
    required String userId,
    required RecordModel record,
  }) async {
    final recordData = record.toJson()..remove('recordId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/records',
      documentId: record.recordId,
      data: recordData,
    );
  }
}
