part of 'bloc.dart';

abstract class TrackerEvent extends Equatable {
  const TrackerEvent();

  @override
  List<Object?> get props => [];
}

class ToggleAdvancedModeEvent extends TrackerEvent {}

class ToggleAnalysisModeEvent extends TrackerEvent {}

class TrackingInteractionEvent extends TrackerEvent {
  final TagEntity tag;

  const TrackingInteractionEvent({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class SelectRecordEvent extends TrackerEvent {
  final String recordId;

  const SelectRecordEvent({required this.recordId});

  @override
  List<Object?> get props => [recordId];
}

class ResetSessionEvent extends TrackerEvent {}

class SaveRecordEvent extends TrackerEvent {
  final String userId;

  const SaveRecordEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FetchRecordsEvent extends TrackerEvent {
  final String userId;

  const FetchRecordsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteRecordEvent extends TrackerEvent {
  final String userId;
  final String recordId;

  const DeleteRecordEvent({required this.userId, required this.recordId});

  @override
  List<Object?> get props => [userId, recordId];
}

class ImportRecordEvent extends TrackerEvent {
  final String userId;

  const ImportRecordEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ShareRecordEvent extends TrackerEvent {
  final String userId;
  final List<CardEntity> cards;

  const ShareRecordEvent({required this.userId, required this.cards});

  @override
  List<Object?> get props => [userId, cards];
}
