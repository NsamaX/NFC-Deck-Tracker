part of 'bloc.dart';

class TrackerState extends Equatable {
  final DeckEntity originalDeck;
  final DeckEntity currentDeck;
  final List<DataEntity> actionLog;
  final bool isAdvancedMode;
  final bool isAnalysisMode;
  final String warningMessage;

  const TrackerState({
    required this.originalDeck,
    required this.currentDeck,
    this.actionLog = const [],
    this.isAdvancedMode = false,
    this.isAnalysisMode = false,
    this.warningMessage = '',
  });

  TrackerState copyWith({
    DeckEntity? originalDeck,
    DeckEntity? currentDeck,
    List<DataEntity>? actionLog,
    bool? isAdvancedMode,
    bool? isAnalysisMode,
    String? warningMessage,
  }) {
    return TrackerState(
      originalDeck: originalDeck ?? this.originalDeck,
      currentDeck: currentDeck ?? this.currentDeck,
      actionLog: actionLog ?? this.actionLog,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      isAnalysisMode: isAnalysisMode ?? this.isAnalysisMode,
      warningMessage: warningMessage ?? this.warningMessage,
    );
  }

  @override
  List<Object?> get props => [
        originalDeck,
        currentDeck,
        actionLog,
        isAdvancedMode,
        isAnalysisMode,
        warningMessage,
      ];
}
