part of 'deck_bloc.dart';

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

class FetchCardInDeckEvent extends DeckEvent {
  final String deckId;

  const FetchCardInDeckEvent({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}

class AddCardEvent extends DeckEvent {
  final CardEntity card;
  final int quantity;

  const AddCardEvent({
    required this.card,
    required this.quantity,
  });

  @override
  List<Object?> get props => [card, quantity];
}

class RemoveCardEvent extends DeckEvent {
  final CardEntity card;
  const RemoveCardEvent({required this.card});

  @override
  List<Object?> get props => [card];
}

class SelectCardEvent extends DeckEvent {
  final CardEntity card;
  const SelectCardEvent({required this.card});

  @override
  List<Object?> get props => [card];
}

class DefaultDeckEvent extends DeckEvent {
  final AppLocalization locale;
  const DefaultDeckEvent({required this.locale});

  @override
  List<Object?> get props => [locale];
}

class CreateDeckEvent extends DeckEvent {
  final String userId;
  const CreateDeckEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteDeckEvent extends DeckEvent {
  final String userId;
  final String deckId;
  final AppLocalization locale;

  const DeleteDeckEvent({
    required this.userId,
    required this.deckId,
    required this.locale,
  });

  @override
  List<Object?> get props => [userId, deckId, locale];
}

class UpdateDeckEvent extends DeckEvent {
  final String userId;
  const UpdateDeckEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SetCurrentDeckEvent extends DeckEvent {
  final String deckId;
  const SetCurrentDeckEvent({required this.deckId});

  @override
  List<Object?> get props => [deckId];
}

class SetDeckNameEvent extends DeckEvent {
  final String name;
  const SetDeckNameEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class SetCardQuantityEvent extends DeckEvent {
  final int quantity;
  const SetCardQuantityEvent({required this.quantity});

  @override
  List<Object?> get props => [quantity];
}

class ToggleShareEvent extends DeckEvent {
  final AppLocalization locale;
  const ToggleShareEvent({required this.locale});

  @override
  List<Object?> get props => [locale];
}

class ToggleDeleteEvent extends DeckEvent {
  final String userId;
  final String deckId;
  const ToggleDeleteEvent({required this.userId, required this.deckId});

  @override
  List<Object?> get props => [userId, deckId];
}

class ToggleEditModeEvent extends DeckEvent {}

class CloseEditModeEvent extends DeckEvent {}
