part of 'bloc.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecordEvent extends RecordEvent {
  final String userId;
  final String deckId;

  const FetchRecordEvent({
    required this.userId, 
    required this.deckId,
  });

  @override
  List<Object?> get props => [userId, deckId];
}

class FindRecordEvent extends RecordEvent {
  final String recordId;

  const FindRecordEvent({
    required this.recordId,
  });

  @override
  List<Object?> get props => [recordId];
}

class ImportRecordEvent extends RecordEvent {
  final String userId;

  const ImportRecordEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class ShareRecordEvent extends RecordEvent {
  final String userId;
  final List<CardEntity> cards;

  const ShareRecordEvent({
    required this.userId,
    required this.cards,
  });

  @override
  List<Object?> get props => [userId, cards];
}

class GetCardFromRecordEvent extends RecordEvent {
  final String recordId;
  final DeckEntity deck;

  const GetCardFromRecordEvent({
    required this.recordId, 
    required this.deck,
  });

  @override
  List<Object?> get props => [recordId, deck];
}

class CreateRecordEvent extends RecordEvent {
  final String userId;

  const CreateRecordEvent({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class DeleteRecordEvent extends RecordEvent {
  final String userId;
  final String recordId;

  const DeleteRecordEvent({
    required this.userId, 
    required this.recordId,
  });

  @override
  List<Object?> get props => [userId, recordId];
}

class UpdateRecordEvent extends RecordEvent {
  final DataEntity data;

  const UpdateRecordEvent({
    required this.data,
  });

  @override
  List<Object?> get props => [data];
}

class ResetRecordEvent extends RecordEvent {}
