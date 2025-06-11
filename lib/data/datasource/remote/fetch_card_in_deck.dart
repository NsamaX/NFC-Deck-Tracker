import '../../model/card.dart';
import '../../model/deck.dart';

import '@firestore_service.dart';

class FetchCardInDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchCardInDeckRemoteDatasource(this._firestoreService);

  Future<List<CardInDeckModel>> fetchCardInDeck({
    required String userId,
    required String deckId,
  }) async {
    final cardSnapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/decks/$deckId/cards',
    );

    final List<CardInDeckModel> cards = [];

    for (final cardDoc in cardSnapshot) {
      final cardData = cardDoc.data();

      final String? collectionId = cardData['collectionId'];
      final String cardId = cardData['cardId'];
      final int count = cardData['count'];

      final CardModel? card = await _fetchCardById(
        userId: userId,
        collectionId: collectionId,
        cardId: cardId,
      );

      if (card != null) {
        cards.add(CardInDeckModel(
          card: card,
          count: count,
        ));
      }
    }

    return cards;
  }

  Future<CardModel?> _fetchCardById({
    required String userId,
    required String? collectionId,
    required String cardId,
  }) async {
    if (collectionId == null) return null;

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
