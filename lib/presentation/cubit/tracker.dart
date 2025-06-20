import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/track_card_interaction.dart';

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
    safeEmit(state.copyWith(
      currentDeck: state.originalDeck,
      actionLog: [],
    ));
  }
}

class TrackerState extends Equatable {
  final bool isProcessing;
  final String warningMessage;

  final bool isDialogVisible;
  final bool isAdvancedMode;
  final bool isAnalysisMode;

  final DeckEntity originalDeck;
  final DeckEntity currentDeck;
  final List<DataEntity> actionLog;

  const TrackerState({
    this.isProcessing = false,
    this.warningMessage = '',
    this.isDialogVisible = false,
    this.isAdvancedMode = false,
    this.isAnalysisMode = false,
    required this.originalDeck,
    required this.currentDeck,
    this.actionLog = const [],
  });

  TrackerState copyWith({
    bool? isProcessing,
    String? warningMessage,
    bool? isDialogVisible,
    bool? isAdvancedMode,
    bool? isAnalysisMode,
    DeckEntity? originalDeck,
    DeckEntity? currentDeck,
    List<DataEntity>? actionLog,
  }) {
    return TrackerState(
      isProcessing: isProcessing ?? this.isProcessing,
      warningMessage: warningMessage ?? this.warningMessage,
      isDialogVisible: isDialogVisible ?? this.isDialogVisible,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      isAnalysisMode: isAnalysisMode ?? this.isAnalysisMode,
      originalDeck: originalDeck ?? this.originalDeck,
      currentDeck: currentDeck ?? this.currentDeck,
      actionLog: actionLog ?? this.actionLog,
    );
  }

  @override
  List<Object?> get props => [
        isProcessing,
        warningMessage,
        isDialogVisible,
        isAdvancedMode,
        isAnalysisMode,
        originalDeck,
        currentDeck,
        actionLog,
      ];
}
