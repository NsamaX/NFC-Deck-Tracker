import '../../model/collection.dart';

import '@firestore_service.dart';

class FetchCollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchCollectionRemoteDatasource(this._firestoreService);

  Future<List<CollectionModel>> fetchCollection({
    required String userId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/collections',
    );

    return snapshot.map((doc) {
      final data = doc.data();
      return CollectionModel.fromJson({
        ...data,
        'collectionId': doc.id,
      });
    }).toList();
  }
}
