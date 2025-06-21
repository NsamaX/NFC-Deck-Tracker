import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/track_card_interaction.dart';

part 'event.dart';
part 'state.dart';

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final TrackCardInteractionUsecase trackCardInteractionUsecase;

  TrackerBloc({
    required DeckEntity deck,
    required this.trackCardInteractionUsecase,
  }) : super(TrackerState(
          originalDeck: deck,
          currentDeck: deck,
        )) {
    on<HandleTagScanEvent>(_onHandleTagScan);
    on<ShowAlertDialogEvent>(_onShowDialog);
    on<ToggleAdvancedModeEvent>(_onToggleAdvanced);
    on<ToggleAnalysisModeEvent>(_onToggleAnalysis);
    on<ResetDeckEvent>(_onResetDeck);
  }

  void _onHandleTagScan(HandleTagScanEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(
      isProcessing: true,
      warningMessage: '',
    ));

    final result = trackCardInteractionUsecase(
      deck: state.currentDeck,
      logs: state.actionLog,
      tag: event.tag,
    );

    if (result.errorKey != null) {
      emit(state.copyWith(
        warningMessage: result.errorKey,
        isProcessing: false,
      ));
      return;
    }

    if (result.newLog == null) {
      emit(state.copyWith(isProcessing: false));
      return;
    }

    emit(state.copyWith(
      currentDeck: result.updatedDeck,
      actionLog: [...state.actionLog, result.newLog!],
      isProcessing: false,
    ));
  }

  void _onShowDialog(ShowAlertDialogEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isDialogVisible: true));
  }

  void _onToggleAdvanced(ToggleAdvancedModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAdvancedMode: !state.isAdvancedMode));
  }

  void _onToggleAnalysis(ToggleAnalysisModeEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(isAnalysisMode: !state.isAnalysisMode));
  }

  void _onResetDeck(ResetDeckEvent event, Emitter<TrackerState> emit) {
    emit(state.copyWith(
      currentDeck: state.originalDeck,
      actionLog: [],
    ));
  }
}
