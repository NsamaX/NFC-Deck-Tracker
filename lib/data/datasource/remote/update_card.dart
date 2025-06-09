import '@firestore_service.dart';

import '../../model/card.dart';

class UpdateCardRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateCardRemoteDatasource(this._firestoreService);

  Future<bool> updateCard({
    required String userId,
    required CardModel card,
  }) async {
    final cardData = card.toJson()
      ..remove('collectionId')
      ..remove('cardId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/collections/${card.collectionId}/cards',
      documentId: card.cardId,
      data: cardData,
    );
  }
}
