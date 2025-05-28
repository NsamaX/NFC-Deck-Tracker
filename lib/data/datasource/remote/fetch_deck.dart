import '_firestore_service.dart';

import '../../model/deck.dart';

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

      final cardSnapshot = await _firestoreService.queryCollection(
        collectionPath: 'users/$userId/decks/${doc.id}/cards',
      );

      final List<Map<String, dynamic>> cardListJson = [];

      for (final cardDoc in cardSnapshot) {
        final cardData = cardDoc.data();
        try {
          cardListJson.add({
            'card': cardData['card'],
            'count': cardData['count'],
          });
        } catch (_) {}
      }

      final fullData = {
        ...data,
        'deckId': doc.id,
        'cards': cardListJson,
      };

      decks.add(DeckModel.fromJson(fullData));
    }

    return decks;
  }
}
