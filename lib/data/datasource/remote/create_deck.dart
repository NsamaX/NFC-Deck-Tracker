import '_firestore_service.dart';

import '../../model/deck.dart';

class CreateDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateDeckRemoteDatasource(this._firestoreService);

  Future<bool> createDeck({
    required String userId,
    required DeckModel deck,
  }) async {
    final deckData = deck.toJson()..remove('cards');

    await _firestoreService.insert(
      collectionPath: 'users/$userId/decks',
      documentId: deck.deckId,
      data: deckData,
    );

    for (final cardInDeck in deck.cards) {
      await _firestoreService.insert(
        collectionPath: 'users/$userId/decks/${deck.deckId}/cards',
        documentId: '${cardInDeck.card.collectionId}_${cardInDeck.card.cardId}',
        data: cardInDeck.toJson(),
      );
    }

    return true;
  }
}
