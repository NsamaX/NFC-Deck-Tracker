import '../../model/card_in_deck.dart';
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

      final List<CardInDeckModel> cards = [];
      final rawCards = data['cards'];

      if (rawCards != null && rawCards is List) {
        for (final cardJson in rawCards) {
          try {
            cards.add(CardInDeckModel.fromJson(cardJson));
          } catch (e) {}
        }
      }

      final DeckModel deck = DeckModel(
        deckId: doc.id,
        name: data['name'],
        cards: cards,
        isSynced: (data['isSynced'] == true || data['isSynced'] == 1),
        updatedAt: DateTime.parse(data['updatedAt']),
      );

      decks.add(deck);
    }

    return decks;
  }
}
