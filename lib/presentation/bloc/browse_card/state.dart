part of 'bloc.dart';

class BrowseCardState extends Equatable {
  final bool isLoading;
  final String errorMessage;
  final List<CardEntity> cards;
  final List<CardEntity> visibleCards;

  const BrowseCardState({
    this.isLoading = false,
    this.errorMessage = '',
    this.cards = const [],
    this.visibleCards = const [],
  });

  BrowseCardState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<CardEntity>? cards,
    List<CardEntity>? visibleCards,
  }) {
    return BrowseCardState(
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
