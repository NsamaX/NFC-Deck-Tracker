part of 'bloc.dart';

abstract class DeckBuilderEvent extends Equatable {
  const DeckBuilderEvent();

  @override
  List<Object?> get props => [];
}

class NewDeckEvent extends DeckBuilderEvent {
  final String name;

  const NewDeckEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class OpenDeckEvent extends DeckBuilderEvent {
  final DeckEntity deck;

  const OpenDeckEvent({required this.deck});

  @override
  List<Object?> get props => [deck];
}

class AddCardEvent extends DeckBuilderEvent {
  final CardEntity card;
  final int quantity;

  const AddCardEvent({required this.card, this.quantity = 1});

  @override
  List<Object?> get props => [card, quantity];
}

class RemoveCardEvent extends DeckBuilderEvent {
  final CardEntity card;

  const RemoveCardEvent({required this.card});

  @override
  List<Object?> get props => [card];
}

class SelectCardEvent extends DeckBuilderEvent {
  final CardEntity card;

  const SelectCardEvent({required this.card});

  @override
  List<Object?> get props => [card];
}

class SetDeckNameEvent extends DeckBuilderEvent {
  final String name;

  const SetDeckNameEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class SetCardQuantityEvent extends DeckBuilderEvent {
  final int quantity;

  const SetCardQuantityEvent({required this.quantity});

  @override
  List<Object?> get props => [quantity];
}

class SaveDeckEvent extends DeckBuilderEvent {
  final String userId;

  const SaveDeckEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ShareEvent extends DeckBuilderEvent {
  final String nameLabel;
  final String totalLabel;

  const ShareEvent({required this.nameLabel, required this.totalLabel});

  @override
  List<Object?> get props => [nameLabel, totalLabel];
}

class ToggleEditModeEvent extends DeckBuilderEvent {}

class CloseEditModeEvent extends DeckBuilderEvent {}
