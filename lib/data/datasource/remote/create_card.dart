import '../../model/card.dart';

import '@firestore_service.dart';

class CreateCardRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateCardRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required CardModel card,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/collections/${card.collectionId}/cards',
      documentId: card.cardId,
      data: card.toJson(),
    );
  }
}
