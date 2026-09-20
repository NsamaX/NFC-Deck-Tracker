part of 'bloc.dart';

abstract class DeckEvent extends Equatable {
  const DeckEvent();

  @override
  List<Object?> get props => [];
}

class FetchDeckEvent extends DeckEvent {
  final String userId;

  const FetchDeckEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteDeckEvent extends DeckEvent {
  final String userId;
  final String deckId;

  const DeleteDeckEvent({required this.userId, required this.deckId});

  @override
  List<Object?> get props => [userId, deckId];
}
