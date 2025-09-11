import '@firestore_service.dart';

class DeleteDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteDeckRemoteDatasource(this._firestoreService);

  Future<bool> delete({
    required String userId,
    required String deckId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/decks',
      documentId: deckId,
    );
  }
}
