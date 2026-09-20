import '../entity/deck.dart';
import '../entity/record.dart';
import '../entity/record_summary.dart';
import '../entity/usage_card_stats.dart';
import '../value/player_action.dart';

class SummarizeRecordUsecase {
  const SummarizeRecordUsecase();

  RecordSummary call({
    required DeckEntity deck,
    required RecordEntity record,
    required List<UsageCardStats> stats,
  }) {
    final totalCards = deck.cards.fold(0, (sum, e) => sum + e.count);
    final takes = record.data.where((e) => e.playerAction == PlayerAction.take);
    final playedTags = takes.map((e) => e.tagId).toSet().length;
    final drawnCardIds = takes.map((e) => e.cardId).toSet();
    final allNames = deck.cards.map((e) => e.card.name).toSet();
    final drawnNames = deck.cards
        .where((e) => drawnCardIds.contains(e.card.cardId))
        .map((e) => e.card.name)
        .toSet();

    return RecordSummary(
      totalDraw: stats.fold(0, (sum, s) => sum + s.drawCount),
      totalReturn: stats.fold(0, (sum, s) => sum + s.returnCount),
      percentagePlayed: totalCards == 0 ? 0 : playedTags / totalCards * 100,
      unusedCardCount: allNames.difference(drawnNames).length,
    );
  }
}
