import '../../model/record.dart';

import '@firestore_service.dart';

class CreateRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateRecordRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required RecordModel record,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/records',
      documentId: record.recordId,
      data: record.toJson(),
    );
  }
}
