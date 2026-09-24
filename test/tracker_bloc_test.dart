import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/share_record.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/repository/record.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/get_card_from_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/import_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/share_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/summarize_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/tracking_interaction.dart';
import 'package:nfc_deck_tracker/domain/value/player_action.dart';
import 'package:nfc_deck_tracker/presentation/bloc/tracker/bloc.dart';

class MemoryRecords extends Fake implements RecordRepository {
  final local = <String, RecordEntity>{};
  @override
  Future<void> createForLocal({required RecordEntity record}) async =>
      local[record.recordId] = record;
  @override
  Future<List<RecordEntity>> fetchForLocal({required String deckId}) async =>
      local.values.where((r) => r.deckId == deckId).toList();
  @override
  Future<bool> deleteForLocal({required String recordId}) async =>
      local.remove(recordId) != null;
  @override
  Future<ShareRecordEntity?> import({required String userId}) async => null;
}

const a = CardEntity(collectionId: 'c', cardId: 'a', name: 'A');
const b = CardEntity(collectionId: 'c', cardId: 'b', name: 'B');
const deck = DeckEntity(
  deckId: 'd',
  name: 'D',
  cards: [
    CardInDeckEntity(card: a, count: 1),
    CardInDeckEntity(card: b, count: 1)
  ],
);

DataEntity take(String cardId) => DataEntity(
      tagId: 't-$cardId',
      collectionId: 'c',
      cardId: cardId,
      location: 'hand',
      playerAction: PlayerAction.take,
      timestamp: DateTime(2024),
    );

TrackerBloc makeBloc(MemoryRecords repository) => TrackerBloc(
      deck: deck,
      trackingInteractionUsecase: TrackingInteractionUsecase(),
      calculateUsageCardUsecase: CalculateUsageCardUsecase(),
      summarizeRecordUsecase: const SummarizeRecordUsecase(),
      getCardFromRecordUsecase: GetCardFromRecordUsecase(),
      fetchRecordUsecase: FetchRecordUsecase(recordRepository: repository),
      createRecordUsecase: CreateRecordUsecase(recordRepository: repository),
      deleteRecordUsecase: DeleteRecordUsecase(recordRepository: repository),
      importRecordUsecase: ImportRecordUsecase(recordRepository: repository),
      shareRecordUsecase: ShareRecordUsecase(recordRepository: repository),
    );

void main() {
  test('selecting a record exposes that record\'s played cards and stats',
      () async {
    final repository = MemoryRecords()
      ..local['r1'] =
          RecordEntity(deckId: 'd', recordId: 'r1', data: [take('a')])
      ..local['r2'] =
          RecordEntity(deckId: 'd', recordId: 'r2', data: [take('b')]);
    final bloc = makeBloc(repository);

    bloc.add(const FetchRecordsEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.records.length == 2);

    bloc.add(const SelectRecordEvent(recordId: 'r1'));
    await bloc.stream.firstWhere((s) => s.usageStats.isNotEmpty);
    expect(bloc.state.playedCards.map((c) => c.cardId), ['a']);

    bloc.add(const SelectRecordEvent(recordId: 'r2'));
    await bloc.stream.firstWhere((s) => s.selectionCount == 2);
    await bloc.stream.firstWhere((s) => s.usageStats.single.cardName == 'B');
    expect(bloc.state.playedCards.map((c) => c.cardId), ['b']);
    expect(bloc.state.isAnalysisMode, isTrue);
    await bloc.close();
  });

  test('saving a record stores it and starts a fresh session', () async {
    final repository = MemoryRecords();
    final bloc = makeBloc(repository);
    bloc.add(TrackingInteractionEvent(tag: take('a')));
    await bloc.stream.firstWhere((s) => s.actionLog.isNotEmpty);

    bloc.add(const SaveRecordEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.records.length == 1);
    expect(repository.local.length, 1);
    expect(bloc.state.actionLog, isEmpty);
    expect(bloc.state.usageStats, isEmpty);
    expect(bloc.state.currentDeck, deck);
    await bloc.close();
  });

  test('tracking reports a card outside the deck and applies one inside it',
      () {
    final track = TrackingInteractionUsecase();
    final outside = track(
        deck: deck,
        logs: const [],
        tag: const TagEntity(tagId: 't', cardId: 'x', collectionId: 'c'));
    expect(outside.outcome, TrackingOutcome.notInDeck);
    expect(outside.newLog, isNull);

    final inside = track(
        deck: deck,
        logs: const [],
        tag: const TagEntity(tagId: 't', cardId: 'a', collectionId: 'c'));
    expect(inside.outcome, TrackingOutcome.applied);
    expect(inside.newLog!.playerAction, PlayerAction.take);

    final exhausted = track(
        deck: inside.updatedDeck,
        logs: const [],
        tag: const TagEntity(tagId: 't2', cardId: 'a', collectionId: 'c'));
    expect(exhausted.outcome, TrackingOutcome.ignored);
  });

  test('a tag outside the deck surfaces as a tracker warning', () async {
    final bloc = makeBloc(MemoryRecords());
    addTearDown(bloc.close);

    bloc.add(const TrackingInteractionEvent(
        tag: TagEntity(tagId: 't', cardId: 'x', collectionId: 'c')));
    final state =
        await bloc.stream.firstWhere((s) => s.warningMessage.isNotEmpty);
    expect(state.warningMessage,
        'page_deck_tracker.snack_bar_not_part_of_current_deck');
  });
}
