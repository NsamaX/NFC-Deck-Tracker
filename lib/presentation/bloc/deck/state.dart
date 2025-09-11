part of 'bloc.dart';

class DeckState extends Equatable {
  final List<DeckEntity> decks;
  final DeckEntity currentDeck;
  final CardEntity selectedCard;
  final int cardQuantity;
  final bool isEditMode;
  final bool isNewDeck;
  final bool isChange;
  final bool isLoading;

  const DeckState({
    this.decks = const [],
    this.currentDeck = const DeckEntity(),
    this.selectedCard = const CardEntity(),
    this.cardQuantity = 1,
    this.isEditMode = false,
    this.isNewDeck = false,
    this.isChange = false,
    this.isLoading = false,
  });

  DeckState copyWith({
    List<DeckEntity>? decks,
    DeckEntity? currentDeck,
    CardEntity? selectedCard,
    int? cardQuantity,
    bool? isEditMode,
    bool? isNewDeck,
    bool? isChange,
    bool? isLoading,
  }) {
    return DeckState(
      decks: decks ?? this.decks,
      currentDeck: currentDeck ?? this.currentDeck,
      selectedCard: selectedCard ?? this.selectedCard,
      cardQuantity: cardQuantity ?? this.cardQuantity,
      isEditMode: isEditMode ?? this.isEditMode,
      isNewDeck: isNewDeck ?? this.isNewDeck,
      isChange: isChange ?? this.isChange,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        decks,
        currentDeck,
        selectedCard,
        cardQuantity,
        isEditMode,
        isNewDeck,
        isChange,
        isLoading,
      ];
}
