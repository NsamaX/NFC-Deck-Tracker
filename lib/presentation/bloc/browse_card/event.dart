part of 'bloc.dart';

abstract class BrowseCardEvent extends Equatable {
  const BrowseCardEvent();

  @override
  List<Object?> get props => [];
}

class FetchCardsEvent extends BrowseCardEvent {
  final String userId;
  final String collectionId;
  final String collectionName;

  const FetchCardsEvent({
    required this.userId,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  List<Object?> get props => [userId, collectionId, collectionName];
}

class FilterCardByNameEvent extends BrowseCardEvent {
  final String query;

  const FilterCardByNameEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class ResetSearchEvent extends BrowseCardEvent {}
