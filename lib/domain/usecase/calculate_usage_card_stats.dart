import '../entity/card.dart';
import '../entity/deck.dart';
import '../entity/record.dart';
import '../entity/player_action.dart';
import '../entity/usage_card_stats.dart';

class CalculateUsageCardStatsUsecase {

  CalculateUsageCardStatsUsecase();

  Future<List<UsageCardStats>> call({
    required DeckEntity deck,
    required RecordEntity record,
  }) async {
    final drawMap = <String, int>{};
    final returnMap = <String, int>{};
    final cardCache = <String, CardEntity>{};

    for (final log in record.data) {
      final key = '${log.collectionId}:${log.cardId}';

      if (!cardCache.containsKey(key)) {
        CardEntity? card;

        try {
          card = deck.cards
              ?.firstWhere(
                (c) =>
                    c.card.cardId == log.cardId &&
                    c.card.collectionId == log.collectionId,
                orElse: () => CardInDeckEntity(
                  card: CardEntity(
                    collectionId: log.collectionId,
                    cardId: log.cardId,
                    name: 'Unknown',
                  ),
                  count: 0,
                ),
              )
              .card;
        } catch (_) {
          card = null;
        }

        if (card != null) {
          cardCache[key] = card;
        } else {
          cardCache[key] = CardEntity(
            collectionId: log.collectionId,
            cardId: log.cardId,
            name: 'Unknown',
          );
        }
      }

      if (log.playerAction == PlayerAction.draw) {
        drawMap[key] = (drawMap[key] ?? 0) + 1;
      } else if (log.playerAction == PlayerAction.returnToDeck) {
        returnMap[key] = (returnMap[key] ?? 0) + 1;
      }
    }

    return cardCache.entries.map((entry) {
      final key = entry.key;
      final card = entry.value;

      return UsageCardStats(
        cardName: card.name ?? 'Unknown',
        drawCount: drawMap[key] ?? 0,
        returnCount: returnMap[key] ?? 0,
      );
    }).toList();
  }
}
