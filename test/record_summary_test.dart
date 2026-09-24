import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/summarize_record.dart';
import 'package:nfc_deck_tracker/domain/value/player_action.dart';

DataEntity take(String tag, String card,
        [PlayerAction action = PlayerAction.take]) =>
    DataEntity(
      tagId: tag,
      collectionId: 'c',
      cardId: card,
      location: 'hand',
      playerAction: action,
      timestamp: DateTime(2024),
    );

void main() {
  const a = CardEntity(collectionId: 'c', cardId: 'a', name: 'A');
  const b = CardEntity(collectionId: 'c', cardId: 'b', name: 'B');
  const deck = DeckEntity(
    deckId: 'd',
    name: 'D',
    cards: [
      CardInDeckEntity(card: a, count: 2),
      CardInDeckEntity(card: b, count: 2)
    ],
  );

  test('summary counts draws, returns, played share, and unused cards', () {
    final record = RecordEntity(
      deckId: 'd',
      recordId: 'r',
      data: [take('t1', 'a'), take('t2', 'a')],
    );
    const stats = [UsageCardStats(cardName: 'A', drawCount: 2, returnCount: 1)];
    final summary = const SummarizeRecordUsecase()(
        deck: deck, record: record, stats: stats);
    expect(summary.totalDraw, 2);
    expect(summary.totalReturn, 1);
    expect(summary.percentagePlayed, 50);
    expect(summary.unusedCardCount, 1);
  });

  test('an empty deck reports zero percent instead of dividing by zero', () {
    final summary = const SummarizeRecordUsecase()(
      deck: const DeckEntity(),
      record: const RecordEntity(deckId: 'd', recordId: 'r', data: []),
      stats: const [],
    );
    expect(summary.percentagePlayed, 0);
  });

  test('usage stats skip logs without a take or give action', () async {
    final record = RecordEntity(
      deckId: 'd',
      recordId: 'r',
      data: [
        take('t1', 'a'),
        take('t2', 'a', PlayerAction.give),
        take('t3', 'a', PlayerAction.none),
        take('t4', 'b', PlayerAction.unknown),
      ],
    );
    final stats = await CalculateUsageCardUsecase()(deck: deck, record: record);
    expect(stats, const [
      UsageCardStats(cardName: 'A', drawCount: 1, returnCount: 1),
    ]);
  });
}
