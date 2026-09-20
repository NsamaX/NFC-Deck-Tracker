part of 'bloc.dart';

class CollectionState extends Equatable {
  final List<CollectionEntity> collections;
  final List<CardEntity> usedCardsDistinct;
  final bool isLoading;
  final String errorMessage;

  const CollectionState({
    this.collections = const [],
    this.usedCardsDistinct = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  CollectionState copyWith({
    List<CollectionEntity>? collections,
    List<CardEntity>? usedCardsDistinct,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CollectionState(
      collections: collections ?? this.collections,
      usedCardsDistinct: usedCardsDistinct ?? this.usedCardsDistinct,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        collections,
        usedCardsDistinct,
        isLoading,
        errorMessage,
      ];
}
