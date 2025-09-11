part of 'bloc.dart';

class CollectionState extends Equatable {
  final List<CollectionEntity> collections;
  final List<CardEntity> usedCardsDistinct;
  final bool isLoading;

  const CollectionState({
    this.collections = const [],
    this.usedCardsDistinct = const [],
    this.isLoading = false,
  });

  CollectionState copyWith({
    List<CollectionEntity>? collections,
    List<CardEntity>? usedCardsDistinct,
    bool? isLoading,
  }) {
    return CollectionState(
      collections: collections ?? this.collections,
      usedCardsDistinct: usedCardsDistinct ?? this.usedCardsDistinct,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        collections,
        usedCardsDistinct,
        isLoading,
      ];
}
