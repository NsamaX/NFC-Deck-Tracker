import 'package:nfc_deck_tracker/util/player_action.dart';

import '../entity/card.dart';
import '../entity/deck.dart';
import '../entity/record.dart';
import '../entity/usage_card_stats.dart';

class CalculateUsageCardStatsUsecase {
  CalculateUsageCardStatsUsecase();

  Future<List<UsageCardStats>> call({
    required DeckEntity deck,
    required RecordEntity record,
  }) async {
    final cardStats = <String, _CardStatsData>{};

    for (final log in record.data) {
      final key = '${log.collectionId}:${log.cardId}';
      cardStats[key] ??= _CardStatsData(_findOrCreateCard(deck, log as CardEntity));
      
      switch (log.playerAction) {
        case PlayerAction.take:
          cardStats[key]!.drawCount++;
          break;
        case PlayerAction.give:
          cardStats[key]!.returnCount++;
          break;
        case PlayerAction.unknown:
          throw UnimplementedError();
      }
    }

    return cardStats.values
        .map((data) => UsageCardStats(
              cardName: data.card.name ?? 'Unknown',
              drawCount: data.drawCount,
              returnCount: data.returnCount,
            ))
        .toList();
  }

  CardEntity _findOrCreateCard(DeckEntity deck, CardEntity log) {
    try {
      return deck.cards
              ?.firstWhere(
                (c) => c.card.cardId == log.cardId && 
                       c.card.collectionId == log.collectionId,
              )
              .card ??
          _createUnknownCard(log);
    } catch (_) {
      return _createUnknownCard(log);
    }
  }

  CardEntity _createUnknownCard(CardEntity log) => CardEntity(
        collectionId: log.collectionId,
        cardId: log.cardId,
        name: 'Unknown',
      );
}

class _CardStatsData {
  final CardEntity card;
  int drawCount = 0;
  int returnCount = 0;

  _CardStatsData(this.card);
}
