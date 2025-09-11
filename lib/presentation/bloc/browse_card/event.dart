part of 'bloc.dart';

abstract class BrowseCardEvent extends Equatable {
  const BrowseCardEvent();

  @override
  List<Object?> get props => [];
}

class FetchCardEvent extends BrowseCardEvent {
  final String userId;
  final String collectionId;

  const FetchCardEvent({
    required this.userId,
    required this.collectionId,
  });

  @override
  List<Object?> get props => [userId, collectionId];
}

class FilterCardEvent extends BrowseCardEvent {
  final String query;

  const FilterCardEvent({
    required this.query,
  });

  @override
  List<Object?> get props => [query];
}

class ClearFilterEvent extends BrowseCardEvent {}

class DeleteCardEvent extends BrowseCardEvent {
  final String userId;
  final String collectionId;
  final String cardId;
  final String imageUrl;

  const DeleteCardEvent({
    required this.userId,
    required this.collectionId,
    required this.cardId,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [userId, collectionId, cardId, imageUrl];
}
