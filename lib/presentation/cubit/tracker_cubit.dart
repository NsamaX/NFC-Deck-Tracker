import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/tracke_card_interaction.dart';

part 'tracker_state.dart';

class TrackerCubit extends Cubit<TrackerState> {
  final TrackCardInteractionUsecase trackCardInteractionUsecase;

  TrackerCubit({
    required DeckEntity deck,
    required this.trackCardInteractionUsecase,
  }) : super(TrackerState(
          originalDeck: deck,
          currentDeck: deck,
        ));

  void safeEmit(TrackerState newState) {
    if (!isClosed) emit(newState);
  }

  void handleTagScan({required TagEntity tag}) {
    safeEmit(state.copyWith(
      isProcessing: true,
      warningMessage: '',
    ));

    final result = trackCardInteractionUsecase(
      deck: state.currentDeck,
      logs: state.actionLog,
      tag: tag,
    );

    if (result.errorKey != null) {
      safeEmit(state.copyWith(
        warningMessage: result.errorKey,
        isProcessing: false,
      ));
      return;
    }

    if (result.newLog == null) {
      safeEmit(state.copyWith(isProcessing: false));
      return;
    }

    safeEmit(state.copyWith(
      currentDeck: result.updatedDeck,
      actionLog: [...state.actionLog, result.newLog!],
      isProcessing: false,
    ));
  }

  void showAlertDialog() {
    safeEmit(state.copyWith(isDialogVisible: true));
  }

  void toggleAdvancedMode() {
    safeEmit(state.copyWith(isAdvancedMode: !state.isAdvancedMode));
  }

  void toggleAnalysisMode() {
    safeEmit(state.copyWith(isAnalysisMode: !state.isAnalysisMode));
  }

  void toggleResetDeck() {
    safeEmit(state.copyWith(currentDeck: state.originalDeck, actionLog: []));
  }
}
