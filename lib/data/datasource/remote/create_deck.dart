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

    final cardsList = deck.cards.map((cardInDeck) => cardInDeck.toJson()).toList();

    final deckData = deck.toJsonForRemote()
      ..addAll({'cards': cardsList});

    final deckInserted = await _firestoreService.insert(
      collectionPath: deckPath,
      documentId: deck.deckId,
      data: deckData,
    );

    return deckInserted;
  }
}
