import '../../model/deck.dart';

import 'firestore_service.dart';

class DeckRemoteDatasource {
  final FirestoreService _firestoreService;

  DeckRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required DeckModel deck,
  }) async {
    final deckPath = 'users/$userId/decks';

    final cardsList =
        deck.cards.map((cardInDeck) => cardInDeck.toJson()).toList();

    final deckData = deck.toJsonForRemote()..addAll({'cards': cardsList});

    final deckInserted = await _firestoreService.insert(
      collectionPath: deckPath,
      documentId: deck.deckId,
      data: deckData,
    );

    return deckInserted;
  }

  Future<bool> delete({
    required String userId,
    required String deckId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/decks',
      documentId: deckId,
    );
  }

  Future<List<DeckModel>> fetch({
    required String userId,
  }) async {
    final path = 'users/$userId/decks';
    return _firestoreService.fetchDocuments(
      collectionPath: path,
      parse: (id, data) => DeckModel.fromJsonForRemote({...data, 'deckId': id}),
    );
  }

  Future<bool> update({
    required String userId,
    required DeckModel deck,
  }) async {
    final cardsJson =
        deck.cards.map((cardInDeck) => cardInDeck.toJson()).toList();

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
