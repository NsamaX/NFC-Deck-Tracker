import 'package:nfc_deck_tracker/domain/value/player_action.dart';

import '../entity/card.dart';
import '../entity/data.dart';
import '../entity/deck.dart';
import '../entity/record.dart';
import '../entity/usage_card_stats.dart';

class CalculateUsageCardUsecase {
  CalculateUsageCardUsecase();

  Future<List<UsageCardStats>> call({
    required DeckEntity deck,
    required RecordEntity record,
  }) async {
    final cardStats = <String, _CardStatsData>{};

    for (final log in record.data) {
      final action = log.playerAction;
      if (action != PlayerAction.take && action != PlayerAction.give) continue;

      final key = '${log.collectionId}:${log.cardId}';
      final stats =
          cardStats[key] ??= _CardStatsData(_findOrCreateCard(deck, log));
      if (action == PlayerAction.take) {
        stats.drawCount++;
      } else {
        stats.returnCount++;
      }
    }

    return cardStats.values
        .map((data) => UsageCardStats(
              cardName: data.card.name.isEmpty ? 'Unknown' : data.card.name,
              drawCount: data.drawCount,
              returnCount: data.returnCount,
            ))
        .toList();
  }

  CardEntity _findOrCreateCard(DeckEntity deck, DataEntity log) {
    for (final c in deck.cards) {
      if (c.card.cardId == log.cardId &&
          c.card.collectionId == log.collectionId) {
        return c.card;
      }
    }
    return _createUnknownCard(log);
  }

  CardEntity _createUnknownCard(DataEntity log) => CardEntity(
        collectionId: log.collectionId,
        cardId: log.cardId,
        name: 'Unknown Card',
      );
}

class _CardStatsData {
  final CardEntity card;
  int drawCount = 0;
  int returnCount = 0;

  _CardStatsData(this.card);
}
