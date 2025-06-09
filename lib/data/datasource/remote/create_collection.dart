import '@firestore_service.dart';

import '../../model/collection.dart';

class CreateCollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateCollectionRemoteDatasource(this._firestoreService);

  Future<bool> createCollection({
    required String userId,
    required CollectionModel collection,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/collections',
      documentId: collection.collectionId,
      data: collection.toJson(),
    );
  }
}
