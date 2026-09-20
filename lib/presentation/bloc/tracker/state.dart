part of 'bloc.dart';

class TrackerState extends Equatable {
  final DeckEntity originalDeck;
  final DeckEntity currentDeck;
  final RecordEntity currentRecord;
  final List<RecordEntity> records;
  final List<CardEntity> playedCards;
  final List<UsageCardStats> usageStats;
  final RecordSummary summary;
  final bool isAdvancedMode;
  final bool isAnalysisMode;
  final int selectionCount;
  final String warningMessage;
  final String errorMessage;

  const TrackerState({
    required this.originalDeck,
    required this.currentDeck,
    required this.currentRecord,
    this.records = const [],
    this.playedCards = const [],
    this.usageStats = const [],
    this.summary = const RecordSummary(),
    this.isAdvancedMode = false,
    this.isAnalysisMode = false,
    this.selectionCount = 0,
    this.warningMessage = '',
    this.errorMessage = '',
  });

  List<DataEntity> get actionLog => currentRecord.data;

  PlayerAction lastActionOf({
    required String collectionId,
    required String cardId,
  }) {
    for (final entry in actionLog.reversed) {
      if (entry.collectionId == collectionId && entry.cardId == cardId) {
        return entry.playerAction;
      }
    }
    return PlayerAction.none;
  }

  TrackerState copyWith({
    DeckEntity? originalDeck,
    DeckEntity? currentDeck,
    RecordEntity? currentRecord,
    List<RecordEntity>? records,
    List<CardEntity>? playedCards,
    List<UsageCardStats>? usageStats,
    RecordSummary? summary,
    bool? isAdvancedMode,
    bool? isAnalysisMode,
    int? selectionCount,
    String? warningMessage,
    String? errorMessage,
  }) {
    return TrackerState(
      originalDeck: originalDeck ?? this.originalDeck,
      currentDeck: currentDeck ?? this.currentDeck,
      currentRecord: currentRecord ?? this.currentRecord,
      records: records ?? this.records,
      playedCards: playedCards ?? this.playedCards,
      usageStats: usageStats ?? this.usageStats,
      summary: summary ?? this.summary,
      isAdvancedMode: isAdvancedMode ?? this.isAdvancedMode,
      isAnalysisMode: isAnalysisMode ?? this.isAnalysisMode,
      selectionCount: selectionCount ?? this.selectionCount,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        originalDeck,
        currentDeck,
        currentRecord,
        records,
        playedCards,
        usageStats,
        summary,
        isAdvancedMode,
        isAnalysisMode,
        selectionCount,
        warningMessage,
        errorMessage,
      ];
}
