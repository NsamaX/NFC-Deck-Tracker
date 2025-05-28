part of 'search_cubit.dart';

class SearchState extends Equatable {
  final bool isLoading;
  final String errorMessage;

  final List<CardEntity> cards;
  final List<CardEntity> visibleCards;

  const SearchState({
    this.isLoading = false,
    this.errorMessage = '',
    this.cards = const [],
    this.visibleCards = const [],
  });

  SearchState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CardEntity>? cards,
    List<CardEntity>? visibleCards,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      cards: cards ?? this.cards,
      visibleCards: visibleCards ?? this.visibleCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        cards,
        visibleCards,
      ];
}
