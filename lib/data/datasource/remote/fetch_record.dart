import '../../model/record.dart';

import '@firestore_service.dart';

class FetchRecordRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchRecordRemoteDatasource(this._firestoreService);

  Future<List<RecordModel>> fetchRecord({
    required String userId,
    required String deckId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/records',
      queryBuilder: (query) => query.where('deckId', isEqualTo: deckId),
    );

    return snapshot.map((doc) {
      final data = doc.data();
      return RecordModel.fromJson({
        ...data,
        'recordId': doc.id,
      });
    }).toList();
  }
}
