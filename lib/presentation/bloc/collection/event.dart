part of 'bloc.dart';

abstract class CollectionEvent extends Equatable {
  const CollectionEvent();

  @override
  List<Object?> get props => [];
}

class CreateCollectionEvent extends CollectionEvent {
  final String userId;
  final String name;

  const CreateCollectionEvent({
    required this.userId,
    required this.name,
  });

  @override
  List<Object?> get props => [userId, name];
}

class DeleteCollectionEvent extends CollectionEvent {
  final String userId;
  final String collectionId;

  const DeleteCollectionEvent({
    required this.userId,
    required this.collectionId,
  });

  @override
  List<Object?> get props => [userId, collectionId];
}

class FetchCollectionEvent extends CollectionEvent {
  final String userId;

  const FetchCollectionEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
