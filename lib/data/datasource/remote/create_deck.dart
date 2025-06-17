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
    final cardsPath = '$deckPath/${deck.deckId}/cards';

    final deckInserted = await _firestoreService.insert(
      collectionPath: deckPath,
      documentId: deck.deckId,
      data: deck.toJsonForRemote(),
    );

    if (!deckInserted) return false;

    for (final cardInDeck in deck.cards) {
      final inserted = await _firestoreService.insert(
        collectionPath: cardsPath,
        documentId: cardInDeck.card.collectionId,
        data: {
          'cardId': cardInDeck.card.cardId,
          'count': cardInDeck.count,
        },
      );

      if (!inserted) return false;
    }

    return true;
  }
}
