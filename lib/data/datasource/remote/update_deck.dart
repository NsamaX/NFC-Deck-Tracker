import '../../model/deck.dart';

import '@firestore_service.dart';

class UpdateDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateDeckRemoteDatasource(this._firestoreService);

  Future<bool> update({
    required String userId,
    required DeckModel deck,
  }) async {
    final cardsJson = deck.cards.map((cardInDeck) => cardInDeck.toJson()).toList();

    final deckData = deck.toJsonForRemote()
      ..remove('deckId')
      ..addAll({'cards': cardsJson});

    final deckUpdated = await _firestoreService.update(
      collectionPath: 'users/$userId/decks',
      documentId: deck.deckId,
      data: deckData,
    );

    return deckUpdated;
  }
}
