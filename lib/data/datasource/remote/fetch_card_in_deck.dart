import '../../model/card.dart';
import '../../model/card_in_deck.dart';

import '@firestore_service.dart';

class FetchCardInDeckRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchCardInDeckRemoteDatasource(this._firestoreService);

  Future<List<CardInDeckModel>> fetch({
    required String userId,
    required String deckId,
  }) async {
    final deckDoc = await _firestoreService.getDocument(
      collectionPath: 'users/$userId/decks',
      documentId: deckId,
    );

    if (deckDoc == null || deckDoc.data() == null) return [];

    final deckData = deckDoc.data()!;
    final cardsMap = deckData['cards'] ?? {};

    if (cardsMap.isEmpty) return [];

    final collectionId = cardsMap.keys.first;
    final List<dynamic> cardList = cardsMap[collectionId];

    final List<CardInDeckModel> result = [];

    for (final cardItem in cardList) {
      try {
        final cardData = cardItem['card'];
        final count = cardItem['count'];

        if (cardData == null || count == null) continue;

        final card = CardModel.fromJson(cardData);

        result.add(CardInDeckModel(card: card, count: count));
      } catch (e) {
        continue;
      }
    }

    return result;
  }
}
