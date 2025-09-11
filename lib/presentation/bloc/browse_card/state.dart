part of 'bloc.dart';

class BrowseCardState extends Equatable {
  final List<CardEntity> cards;
  final List<CardEntity> visibleCards;

  final bool isLoading;
  final String errorMessage;

  const BrowseCardState({
    this.cards = const [],
    this.visibleCards = const [],

    this.isLoading = false,
    this.errorMessage = '',
  });

  BrowseCardState copyWith({
    List<CardEntity>? cards,
    List<CardEntity>? visibleCards,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BrowseCardState(
      cards: cards ?? this.cards,
      visibleCards: visibleCards ?? this.visibleCards,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        visibleCards,
        isLoading,
        errorMessage,
      ];
}
