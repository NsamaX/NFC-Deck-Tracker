import '../entity/card.dart';
import '../entity/deck.dart';
import '../entity/record.dart';
import '../entity/data.dart';

class GetCardFromRecordUsecase {
  List<CardEntity> call({
    required RecordEntity record,
    required DeckEntity deck,
  }) {
    final List<CardEntity> playedCards = [];
    final Map<String, CardEntity> cardMap = {};

    deck.cards?.forEach((cardInDeck) {
      final key = '${cardInDeck.card.collectionId}:${cardInDeck.card.cardId}';
      cardMap[key] = cardInDeck.card;
    });

    for (final DataEntity log in record.data) {
      final String logCollectionId = log.collectionId;
      final String logCardId = log.cardId;
      final String cardKey = '${logCollectionId}:${logCardId}';

      CardEntity? foundCard = cardMap[cardKey];

      if (foundCard != null) {
        playedCards.add(foundCard);
      } else {
        final unknownCard = CardEntity(
          collectionId: logCollectionId,
          cardId: logCardId,
          name: 'Unknown Card',
        );
        playedCards.add(unknownCard);
      }
    }

    return playedCards;
  }
}
