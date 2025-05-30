import '_firestore_service.dart';

import '../../model/deck.dart';

class UpdateDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateDeckRemoteDatasource(this._firestoreService);

  Future<bool> updateDeck({
    required String userId,
    required DeckModel deck,
  }) async {
    final deckData = deck.toJson()
      ..remove('deckId')
      ..remove('cards');

    await _firestoreService.update(
      collectionPath: 'users/$userId/decks',
      documentId: deck.deckId,
      data: deckData,
    );

    final deckCardsPath = 'users/$userId/decks/${deck.deckId}/cards';

    final remoteSnapshot = await _firestoreService.queryCollection(
      collectionPath: deckCardsPath,
    );
    final remoteIds = remoteSnapshot.map((doc) => doc.id).toSet();
    final localIds = deck.cards
        .map((c) => '${c.card.collectionId}_${c.card.cardId}')
        .toSet();
    final idsToDelete = remoteIds.difference(localIds);

    for (final id in idsToDelete) {
      await _firestoreService.delete(
        collectionPath: deckCardsPath,
        documentId: id,
      );
    }

    for (final cardInDeck in deck.cards) {
      final cardId = '${cardInDeck.card.collectionId}_${cardInDeck.card.cardId}';

      await _firestoreService.insert(
        collectionPath: deckCardsPath,
        documentId: cardId,
        data: cardInDeck.toJson(),
        merge: true,
      );
    }

    return true;
  }
}
