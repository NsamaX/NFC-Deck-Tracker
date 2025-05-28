part of 'tracker_cubit.dart';

class TrackerState extends Equatable {
  final bool isProcessing;
  final String errorMessage;

  final bool isDialogVisible;
  final bool isAdvancedMode;
  final bool isAnalysisMode;

  final DeckEntity originalDeck;
  final DeckEntity currentDeck;
  final List<DataEntity> actionLog;

  const TrackerState({
    this.isProcessing = false,
    this.errorMessage = '',
    this.isDialogVisible = false,
    this.isAdvancedMode = false,
    this.isAnalysisMode = false,
    required this.originalDeck,
    required this.currentDeck,
    this.actionLog = const [],
  });

  TrackerState copyWith({
    bool? isProcessing,
    String? errorMessage,
    bool? isDialogVisible,
    bool? isAdvancedMode,
    bool? isAnalysisMode,
    DeckEntity? originalDeck,
    DeckEntity? currentDeck,
    List<DataEntity>? actionLog,
  }) {
    return TrackerState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
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
        errorMessage,
        isDialogVisible,
        isAdvancedMode,
        isAnalysisMode,
        originalDeck,
        currentDeck,
        actionLog,
      ];
}
