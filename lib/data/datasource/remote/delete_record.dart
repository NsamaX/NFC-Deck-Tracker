import '_firestore_service.dart';

class DeleteRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteRecordRemoteDatasource(this._firestoreService);

  Future<bool> deleteRecord({
    required String userId,
    required String recordId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/records',
      documentId: recordId,
    );
  }
}
