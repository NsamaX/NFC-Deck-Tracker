part of 'bloc.dart';

abstract class PinCardEvent extends Equatable {
  const PinCardEvent();

  @override
  List<Object?> get props => [];
}

class PinColorEvent extends PinCardEvent {
  final String cardId;
  final Color color;

  const PinColorEvent({required this.cardId, required this.color});

  @override
  List<Object?> get props => [cardId, color];
}

class RemoveColorEvent extends PinCardEvent {
  final String cardId;

  const RemoveColorEvent({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class ResetColorEvent extends PinCardEvent {}
