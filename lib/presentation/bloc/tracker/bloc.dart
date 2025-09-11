import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/tracking_interaction.dart';

part 'event.dart';
part 'state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final TrackingInteractionUsecase trackingInteractionUsecase;

  TrackerBloc({
    required DeckEntity deck,
    required this.trackingInteractionUsecase,
  }) : super(TrackerState(
          originalDeck: deck,
          currentDeck: deck,
        )) {
    on<ToggleAdvancedModeEvent>(_onToggleAdvancedMode);
    on<ToggleAnalysisModeEvent>(_onToggleAnalysisMode);
    on<TrackingInteractionEvent>(_onTrackingInteraction);
    on<LoadDeckFromRecordEvent>(_onLoadDeckFromRecord);
    on<ResetDeckEvent>(_onResetDeck);
  }

  void _onToggleAdvancedMode(ToggleAdvancedModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAdvancedMode: !state.isAdvancedMode));
  }

  void _onToggleAnalysisMode(ToggleAnalysisModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAnalysisMode: !state.isAnalysisMode));
  }

  void _onTrackingInteraction(TrackingInteractionEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(warningMessage: ''));

    final result = trackingInteractionUsecase(deck: state.currentDeck, logs: state.actionLog, tag: event.tag);

    if (result.errorKey != null) {
      emit(state.copyWith(warningMessage: result.errorKey));
      return;
    }

    if (result.newLog == null) return;

    final updatedActionLog = [...state.actionLog, result.newLog!];
    emit(state.copyWith(currentDeck: result.updatedDeck, actionLog: updatedActionLog));
  }

  void _onLoadDeckFromRecord(LoadDeckFromRecordEvent event, Emitter<TrackerState> emit) {
    DeckEntity simulatedDeck = state.originalDeck;
    List<DataEntity> simulatedActionLog = [];

    for (final log in event.record.data) {
      final result = trackingInteractionUsecase(
        deck: simulatedDeck,
        logs: simulatedActionLog,
        tag: TagEntity(tagId: log.tagId, collectionId: log.collectionId, cardId: log.cardId),
      );

      if (result.newLog != null) {
        simulatedDeck = result.updatedDeck;
        simulatedActionLog = [...simulatedActionLog, result.newLog!];
        simulatedActionLog.removeLast();
      }
    }

    emit(state.copyWith(
      currentDeck: simulatedDeck,
      actionLog: simulatedActionLog,
      isAnalysisMode: true,
    ));
  }

  void _onResetDeck(ResetDeckEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(currentDeck: state.originalDeck, actionLog: []));
  }
}
