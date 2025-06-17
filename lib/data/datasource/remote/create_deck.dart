import '../../model/deck.dart';

import '@firestore_service.dart';

class CreateDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateDeckRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required DeckModel deck,
  }) async {
    final deckInserted = await _firestoreService.insert(
      collectionPath: 'users/$userId/decks',
      documentId: deck.deckId,
      data: deck.toJsonForDeck(),
    );

    if (!deckInserted) return false;

    for (final cardInDeck in deck.cards) {
      final inserted = await _firestoreService.insert(
        collectionPath: 'users/$userId/decks/${deck.deckId}/cards',
        documentId: cardInDeck.card.cardId,
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
