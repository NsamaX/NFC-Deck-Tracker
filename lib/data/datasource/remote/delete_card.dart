import '_firestore_service.dart';

class DeleteCardRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteCardRemoteDatasource(this._firestoreService);

  Future<bool> deleteCard({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/collections/$collectionId/cards',
      documentId: cardId,
    );
  }
}
