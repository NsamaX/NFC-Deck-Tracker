import '_firestore_service.dart';

class DeleteCollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteCollectionRemoteDatasource(this._firestoreService);

  Future<bool> deleteCollection({
    required String userId,
    required String collectionId,
  }) async {
    final cardsSnapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/collections/$collectionId/cards',
    );

    for (var cardDoc in cardsSnapshot) {
      await _firestoreService.delete(
        collectionPath: 'users/$userId/collections/$collectionId/cards',
        documentId: cardDoc.id,
      );
    }

    return await _firestoreService.delete(
      collectionPath: 'users/$userId/collections',
      documentId: collectionId,
    );
  }
}
