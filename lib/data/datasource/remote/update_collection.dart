import '../../model/collection.dart';

import '@firestore_service.dart';

class UpdateCollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateCollectionRemoteDatasource(this._firestoreService);

  Future<bool> update({
    required String userId,
    required CollectionModel collection,
  }) async {
    final collectionData = collection.toJsonForRemote()..remove('collectionId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/collections',
      documentId: collection.collectionId,
      data: collectionData,
    );
  }
}
