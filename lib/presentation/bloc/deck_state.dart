part of 'deck_bloc.dart';

class DeckState extends Equatable {
  final List<DeckEntity> decks;
  final DeckEntity currentDeck;
  final CardEntity selectedCard;
  final bool isEditMode;
  final bool isNewDeck;
  final int cardQuantity;

  const DeckState({
    this.decks = const [],
    this.currentDeck = const DeckEntity(),
    this.selectedCard = const CardEntity(),
    this.isEditMode = false,
    this.isNewDeck = false,
    this.cardQuantity = 1,
  });

  DeckState copyWith({
    List<DeckEntity>? decks,
    DeckEntity? currentDeck,
    CardEntity? selectedCard,
    bool? isEditMode,
    bool? isNewDeck,
    int? cardQuantity,
  }) {
    return DeckState(
      decks: decks ?? this.decks,
      currentDeck: currentDeck ?? this.currentDeck,
      selectedCard: selectedCard ?? this.selectedCard,
      isEditMode: isEditMode ?? this.isEditMode,
      isNewDeck: isNewDeck ?? this.isNewDeck,
      cardQuantity: cardQuantity ?? this.cardQuantity,
    );
  }

  @override
  List<Object?> get props => [
        decks,
        currentDeck,
        selectedCard,
        isEditMode,
        isNewDeck,
        cardQuantity,
      ];
}
