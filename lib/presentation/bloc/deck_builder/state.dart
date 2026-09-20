part of 'bloc.dart';

class DeckBuilderState extends Equatable {
  final DeckEntity currentDeck;
  final CardEntity selectedCard;
  final int cardQuantity;
  final bool isEditMode;
  final bool isNewDeck;
  final bool isChange;
  final bool isLoading;
  final String shareText;
  final int shareCount;
  final int savedCount;
  final String errorMessage;

  const DeckBuilderState({
    this.currentDeck = const DeckEntity(),
    this.selectedCard = const CardEntity(),
    this.cardQuantity = 1,
    this.isEditMode = false,
    this.isNewDeck = false,
    this.isChange = false,
    this.isLoading = false,
    this.shareText = '',
    this.shareCount = 0,
    this.savedCount = 0,
    this.errorMessage = '',
  });

  DeckBuilderState copyWith({
    DeckEntity? currentDeck,
    CardEntity? selectedCard,
    int? cardQuantity,
    bool? isEditMode,
    bool? isNewDeck,
    bool? isChange,
    bool? isLoading,
    String? shareText,
    int? shareCount,
    int? savedCount,
    String? errorMessage,
  }) {
    return DeckBuilderState(
      currentDeck: currentDeck ?? this.currentDeck,
      selectedCard: selectedCard ?? this.selectedCard,
      cardQuantity: cardQuantity ?? this.cardQuantity,
      isEditMode: isEditMode ?? this.isEditMode,
      isNewDeck: isNewDeck ?? this.isNewDeck,
      isChange: isChange ?? this.isChange,
      isLoading: isLoading ?? this.isLoading,
      shareText: shareText ?? this.shareText,
      shareCount: shareCount ?? this.shareCount,
      savedCount: savedCount ?? this.savedCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentDeck,
        selectedCard,
        cardQuantity,
        isEditMode,
        isNewDeck,
        isChange,
        isLoading,
        shareText,
        shareCount,
        savedCount,
        errorMessage,
      ];
}
