import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';

import 'package:nfc_deck_tracker/util/player_action.dart';

import '../../locale/localization.dart';

class DeckInsightSummary extends StatelessWidget {
  final DeckEntity initialDeck;
  final RecordEntity currentRecord;
  final List<RecordEntity> allRecord;
  final List<UsageCardStats> usageCardStat;
  final void Function(BuildContext context, String recordId)? selectRecord;

  const DeckInsightSummary({
    super.key,
    required this.initialDeck,
    required this.currentRecord,
    required this.allRecord,
    required this.usageCardStat,
    this.selectRecord,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    final totalDraw = _totalDrawCount();
    final totalReturn = _totalReturnCount();
    final percentagePlayed = _percentagePlayed();
    final unusedCardCount = _unusedCardCount();

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.translate('page_deck_tracker.summerize_title'),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
          ),
          const SizedBox(height: 8.0),
          ...[
            locale.translate('page_deck_tracker.summarize_percentage_played')
                .replaceFirst('{percentage}', percentagePlayed.toStringAsFixed(1)),
            locale.translate('page_deck_tracker.summarize_total_action')
                .replaceFirst('{draw}', '$totalDraw')
                .replaceFirst('{return}', '$totalReturn'),
            locale.translate('page_deck_tracker.summarize_unused_card')
                .replaceFirst('{unused}', '$unusedCardCount'),
          ].map((line) => Text('     ➜ $line', style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  int _totalDrawCount() => usageCardStat.fold(0, (sum, stat) => sum + stat.drawCount);

  int _totalReturnCount() => usageCardStat.fold(0, (sum, stat) => sum + stat.returnCount);

  double _percentagePlayed() {
    final totalCards = (initialDeck.cards ?? []).fold(0, (sum, e) => sum + e.count);
    final playedCardTags = currentRecord.data
        .where((e) => e.playerAction == PlayerAction.take)
        .map((e) => e.tagId)
        .toSet()
        .length;

    return totalCards == 0 ? 0.0 : (playedCardTags / totalCards) * 100;
  }

  int _unusedCardCount() {
    final allCardNames = (initialDeck.cards ?? []).map((e) => e.card.name).toSet();
    final drawnCardIds = currentRecord.data
        .where((e) => e.playerAction == PlayerAction.take)
        .map((e) => e.cardId)
        .toSet();
    final drawnCardNames = (initialDeck.cards ?? [])
        .where((e) => drawnCardIds.contains(e.card.cardId))
        .map((e) => e.card.name)
        .toSet();

    return allCardNames.difference(drawnCardNames).length;
  }
}
