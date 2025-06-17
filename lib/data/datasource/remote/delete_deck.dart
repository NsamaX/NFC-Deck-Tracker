import '@firestore_service.dart';

class DeleteDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteDeckRemoteDatasource(this._firestoreService);

  Future<bool> delete({
    required String userId,
    required String deckId,
  }) async {
    final cardsSnapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/decks/$deckId/cards',
    );

    for (var cardDoc in cardsSnapshot) {
      await _firestoreService.delete(
        collectionPath: 'users/$userId/decks/$deckId/cards',
        documentId: cardDoc.id,
      );
    }

    return await _firestoreService.delete(
      collectionPath: 'users/$userId/decks',
      documentId: deckId,
    );
  }
}
