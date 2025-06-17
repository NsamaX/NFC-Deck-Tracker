import '../../model/deck.dart';

import '@firestore_service.dart';

class CreateDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateDeckRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required DeckModel deck,
  }) async {
    if (deck.cards.isEmpty) return false;

    final deckPath = 'users/$userId/decks';
    final cardsList = deck.toJsonForCardsInDeck();
    final Map<String, List<Map<String, dynamic>>> groupedCards = {};

    for (var card in cardsList) {
      final collectionId = card['collectionId'];
      final cardData = {
        'cardId': card['cardId'],
        'count': card['count'],
      };

      if (!groupedCards.containsKey(collectionId)) {
        groupedCards[collectionId] = [];
      }

      groupedCards[collectionId]!.add(cardData);
    }

    final deckData = deck.toJsonForRemote()..addAll({'cards': groupedCards});

    final deckInserted = await _firestoreService.insert(
      collectionPath: deckPath,
      documentId: deck.deckId,
      data: deckData,
    );

    return deckInserted;
  }
}
