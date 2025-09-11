import '../../model/share_record.dart';

import '@firestore_service.dart';

class ImportRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  ImportRecordRemoteDatasource(this._firestoreService);

  Future<ShareRecordModel?> import({
    required String userId,
  }) async {
    final docSnapshot = await _firestoreService.getDocument(
      collectionPath: 'users/$userId',
      documentId: 'room',
    );

    if (docSnapshot != null && docSnapshot.exists) {
      return ShareRecordModel.fromJson(docSnapshot.data()!);
    } else {
      return null;
    }
  }
}
