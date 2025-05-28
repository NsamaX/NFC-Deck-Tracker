part of 'deck_cubit.dart';

class DeckState extends Equatable {
  final bool isLoading;
  final String errorMessage;

  final bool isEditMode;
  final bool isNewDeck;

  final List<DeckEntity> decks;
  final DeckEntity currentDeck;
  final CardEntity selectedCard;
  final int selectedCardCount;

  DeckState({
    this.isLoading = false,
    this.errorMessage = '',
    this.isEditMode = false,
    this.isNewDeck = false,
    this.decks = const [],
    this.currentDeck = const DeckEntity(),
    this.selectedCard = const CardEntity(),
    this.selectedCardCount = 1,
  });

  DeckState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isEditMode,
    bool? isNewDeck,
    List<DeckEntity>? decks,
    DeckEntity? currentDeck,
    CardEntity? selectedCard,
    int? selectedCardCount,
  }) {
    return DeckState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      isNewDeck: isNewDeck ?? this.isNewDeck,
      decks: decks ?? this.decks,
      currentDeck: currentDeck ?? this.currentDeck,
      selectedCard: selectedCard ?? this.selectedCard,
      selectedCardCount: selectedCardCount ?? this.selectedCardCount,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        isEditMode,
        isNewDeck,
        decks,
        currentDeck,
        selectedCard,
        selectedCardCount,
      ];
}
