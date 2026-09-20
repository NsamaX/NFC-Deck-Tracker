part of 'bloc.dart';

class BrowseCardState extends Equatable {
  final List<CardEntity> cards;
  final String query;
  final bool isLoading;
  final String errorMessage;

  const BrowseCardState({
    this.cards = const [],
    this.query = '',
    this.isLoading = false,
    this.errorMessage = '',
  });

  List<CardEntity> get visibleCards {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return cards;
    return cards
        .where((card) => card.name.toLowerCase().contains(keyword))
        .toList();
  }

  BrowseCardState copyWith({
    List<CardEntity>? cards,
    String? query,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BrowseCardState(
      cards: cards ?? this.cards,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [cards, query, isLoading, errorMessage];
}
