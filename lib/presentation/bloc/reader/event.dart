part of 'bloc.dart';

abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => [];
}

class ReadTagEvent extends ReaderEvent {
  final TagEntity? tag;

  const ReadTagEvent({
    required this.tag,
  });

  @override
  List<Object?> get props => [tag];
}

class SetReadedCardsEvent extends ReaderEvent {
  final List<CardEntity> readedCards;

  const SetReadedCardsEvent({
    required this.readedCards,
  });

  @override
  List<Object?> get props => [readedCards];
}

class ResetReadedCardsEvent extends ReaderEvent {}

class ClearReaderMessagesEvent extends ReaderEvent {}
