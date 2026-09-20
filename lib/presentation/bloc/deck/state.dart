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
  final String errorMessage;
  final String shareText;
  final int shareCount;

  const DeckState({
    this.decks = const [],
    this.currentDeck = const DeckEntity(),
    this.selectedCard = const CardEntity(),
    this.cardQuantity = 1,
    this.isEditMode = false,
    this.isNewDeck = false,
    this.isChange = false,
    this.isLoading = false,
    this.errorMessage = '',
    this.shareText = '',
    this.shareCount = 0,
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
    String? errorMessage,
    String? shareText,
    int? shareCount,
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
      errorMessage: errorMessage ?? this.errorMessage,
      shareText: shareText ?? this.shareText,
      shareCount: shareCount ?? this.shareCount,
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
        errorMessage,
        shareText,
        shareCount,
      ];
}
