import '../../model/deck.dart';

import '@firestore_service.dart';

class FetchDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchDeckRemoteDatasource(this._firestoreService);

  Future<List<DeckModel>> fetch({
    required String userId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/decks',
    );

    final List<DeckModel> decks = [];

    for (final doc in snapshot) {
      final data = doc.data();

      try {
        data['deckId'] = doc.id;

        final deck = DeckModel.fromJsonForRemote(data);
        decks.add(deck);
      } catch (e) {}
    }

    return decks;
  }
}
