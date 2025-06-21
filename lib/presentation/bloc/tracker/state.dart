part of 'bloc.dart';

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
