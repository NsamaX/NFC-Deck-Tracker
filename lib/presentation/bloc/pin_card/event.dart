part of 'bloc.dart';

abstract class PinCardEvent extends Equatable {
  const PinCardEvent();

  @override
  List<Object?> get props => [];
}

class PinColorEvent extends PinCardEvent {
  final String cardId;
  final Color color;

  const PinColorEvent({
    required this.cardId,
    required this.color,
  });

  @override
  List<Object?> get props => [cardId, color];
}
