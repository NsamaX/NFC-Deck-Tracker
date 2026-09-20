import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/record_summary.dart';
import 'package:nfc_deck_tracker/domain/entity/share_record.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
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

import '../error_reporting.dart';

part 'event.dart';
part 'state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState>
    with ErrorReporting<TrackerEvent, TrackerState> {
  final TrackingInteractionUsecase trackingInteractionUsecase;
  final CalculateUsageCardUsecase calculateUsageCardUsecase;
  final SummarizeRecordUsecase summarizeRecordUsecase;
  final GetCardFromRecordUsecase getCardFromRecordUsecase;
  final FetchRecordUsecase fetchRecordUsecase;
  final CreateRecordUsecase createRecordUsecase;
  final DeleteRecordUsecase deleteRecordUsecase;
  final ImportRecordUsecase importRecordUsecase;
  final ShareRecordUsecase shareRecordUsecase;

  TrackerBloc({
    required DeckEntity deck,
    required this.trackingInteractionUsecase,
    required this.calculateUsageCardUsecase,
    required this.summarizeRecordUsecase,
    required this.getCardFromRecordUsecase,
    required this.fetchRecordUsecase,
    required this.createRecordUsecase,
    required this.deleteRecordUsecase,
    required this.importRecordUsecase,
    required this.shareRecordUsecase,
  }) : super(TrackerState(
          originalDeck: deck,
          currentDeck: deck,
          currentRecord:
              RecordEntity(deckId: deck.deckId, recordId: '', data: []),
        )) {
    on<ToggleAdvancedModeEvent>(_onToggleAdvancedMode);
    on<ToggleAnalysisModeEvent>(_onToggleAnalysisMode);
    on<TrackingInteractionEvent>(_onTrackingInteraction);
    on<SelectRecordEvent>(_onSelectRecord);
    on<ResetSessionEvent>(_onResetSession);
    on<SaveRecordEvent>(_onSaveRecord);
    on<FetchRecordsEvent>(_onFetchRecords);
    on<DeleteRecordEvent>(_onDeleteRecord);
    on<ImportRecordEvent>(_onImportRecord);
    on<ShareRecordEvent>(_onShareRecord);
  }

  void _onToggleAdvancedMode(
      ToggleAdvancedModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAdvancedMode: !state.isAdvancedMode));
  }

  void _onToggleAnalysisMode(
      ToggleAnalysisModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAnalysisMode: !state.isAnalysisMode));
  }

  Future<void> _onTrackingInteraction(
      TrackingInteractionEvent event, Emitter<TrackerState> emit) async {
    emit(state.copyWith(warningMessage: ''));

    final result = trackingInteractionUsecase(
        deck: state.currentDeck, logs: state.actionLog, tag: event.tag);

    if (result.errorKey != null) {
      emit(state.copyWith(warningMessage: result.errorKey));
      return;
    }
    if (result.newLog == null) return;

    final record = state.currentRecord
        .copyWith(data: [...state.currentRecord.data, result.newLog!]);
    emit(
        state.copyWith(currentDeck: result.updatedDeck, currentRecord: record));
    await _recalculateUsage(emit, record);
  }

  Future<void> _onSelectRecord(
      SelectRecordEvent event, Emitter<TrackerState> emit) async {
    final record =
        state.records.firstWhere((r) => r.recordId == event.recordId);
    final played =
        getCardFromRecordUsecase(record: record, deck: state.originalDeck);

    DeckEntity simulatedDeck = state.originalDeck;
    List<DataEntity> simulatedLog = [];
    for (final log in record.data) {
      final result = trackingInteractionUsecase(
        deck: simulatedDeck,
        logs: simulatedLog,
        tag: TagEntity(
            tagId: log.tagId,
            collectionId: log.collectionId,
            cardId: log.cardId),
      );
      if (result.newLog != null) simulatedDeck = result.updatedDeck;
    }

    emit(state.copyWith(
      currentRecord: record,
      playedCards: played,
      currentDeck: simulatedDeck,
      isAnalysisMode: true,
      selectionCount: state.selectionCount + 1,
    ));
    await _recalculateUsage(emit, record);
  }

  void _onResetSession(ResetSessionEvent event, Emitter<TrackerState> emit) {
    emit(_freshSession(state));
  }

  Future<void> _onSaveRecord(
      SaveRecordEvent event, Emitter<TrackerState> emit) async {
    await guard(emit, ErrorKeys.save, () async {
      final saved = await createRecordUsecase(
        userId: event.userId,
        record: state.currentRecord.copyWith(createdAt: DateTime.now()),
      );
      emit(_freshSession(state.copyWith(records: [...state.records, saved])));
    });
  }

  Future<void> _onFetchRecords(
      FetchRecordsEvent event, Emitter<TrackerState> emit) async {
    await guard(emit, ErrorKeys.load, () async {
      final records = await fetchRecordUsecase(
          userId: event.userId, deckId: state.originalDeck.deckId);
      emit(state.copyWith(records: records));
    });
  }

  Future<void> _onDeleteRecord(
      DeleteRecordEvent event, Emitter<TrackerState> emit) async {
    await guard(emit, ErrorKeys.delete, () async {
      await deleteRecordUsecase(userId: event.userId, recordId: event.recordId);
      emit(state.copyWith(
          records: state.records
              .where((r) => r.recordId != event.recordId)
              .toList()));
    });
  }

  Future<void> _onImportRecord(
      ImportRecordEvent event, Emitter<TrackerState> emit) async {
    await guard(emit, ErrorKeys.import, () async {
      final shared = await importRecordUsecase(userId: event.userId);
      if (shared == null) return;
      final data = [...state.currentRecord.data, ...shared.data]
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final record = state.currentRecord.copyWith(data: data);
      emit(state.copyWith(currentRecord: record));
      await _recalculateUsage(emit, record);
    });
  }

  Future<void> _onShareRecord(
      ShareRecordEvent event, Emitter<TrackerState> emit) async {
    await guard(emit, ErrorKeys.share, () async {
      await shareRecordUsecase(
        userId: event.userId,
        shareRecord: ShareRecordEntity(
            cards: event.cards, data: state.currentRecord.data),
      );
    });
  }

  Future<void> _recalculateUsage(
      Emitter<TrackerState> emit, RecordEntity record) async {
    final stats = await calculateUsageCardUsecase(
        deck: state.originalDeck, record: record);
    final summary = summarizeRecordUsecase(
        deck: state.originalDeck, record: record, stats: stats);
    emit(state.copyWith(usageStats: stats, summary: summary));
  }

  TrackerState _freshSession(TrackerState from) => from.copyWith(
        currentDeck: from.originalDeck,
        currentRecord: RecordEntity(
            deckId: from.originalDeck.deckId, recordId: '', data: []),
        playedCards: const [],
        usageStats: const [],
        summary: const RecordSummary(),
        selectionCount: from.selectionCount + 1,
      );

  @override
  TrackerState withError(TrackerState state, String messageKey) =>
      state.copyWith(errorMessage: messageKey);
}
