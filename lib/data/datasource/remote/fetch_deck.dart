import '../../model/deck.dart';

import '@firestore_service.dart';

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

      final DeckModel deck = DeckModel(
        deckId: doc.id,
        name: data['name'],
        cards: [],
        isSynced: data['isSynced'] == 1,
        updatedAt: DateTime.parse(data['updatedAt']),
      );

      decks.add(deck);
    }

    return decks;
  }
}
