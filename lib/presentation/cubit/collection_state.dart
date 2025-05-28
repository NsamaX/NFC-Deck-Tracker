part of 'collection_cubit.dart';

class CollectionState extends Equatable {
  final List<CollectionEntity> collections;

  const CollectionState({
    this.collections = const [],
  });

  CollectionState copyWith({
    List<CollectionEntity>? collections,
  }) {
    return CollectionState(
      collections: collections ?? this.collections,
    );
  }

  @override
  List<Object?> get props => [collections];
}
