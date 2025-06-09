import '@firestore_service.dart';

import '../../model/card.dart';
import '../../model/deck.dart';

class FetchDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchDeckRemoteDatasource(this._firestoreService);

  Future<List<DeckModel>> fetchDeck({
    required String userId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/decks',
    );

    final List<DeckModel> decks = [];

    for (final doc in snapshot) {
      final data = doc.data();

      final cardSnapshot = await _firestoreService.queryCollection(
        collectionPath: 'users/$userId/decks/${doc.id}/cards',
      );

      final List<Map<String, dynamic>> cardListJson = [];

      for (final cardDoc in cardSnapshot) {
        final cardData = cardDoc.data();

        final String collectionId = cardData['collectionId'];
        final String cardId = cardData['cardId'];
        final int count = cardData['count'];

        final CardModel? card = await _fetchCardById(
          userId: userId,
          collectionId: collectionId,
          cardId: cardId,
        );

        if (card != null) {
          cardListJson.add({
            'card': card.toJson(),
            'count': count,
          });
        }
      }

      final fullData = {
        ...data,
        'deckId': doc.id,
        'cards': cardListJson,
      };

      decks.add(DeckModel.fromJson(fullData));
    }

    return decks;
  }

  Future<CardModel?> _fetchCardById({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    final doc = await _firestoreService.getDocument(
      collectionPath: 'users/$userId/collections/$collectionId/cards',
      documentId: cardId,
    );

    if (doc != null && doc.data() != null) {
      return CardModel.fromJson(doc.data()!);
    }

    return null;
  }
}
