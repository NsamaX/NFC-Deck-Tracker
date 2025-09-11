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

  const TrackingInteractionEvent({
    required this.tag,
  });

  @override
  List<Object?> get props => [tag];
}

class LoadDeckFromRecordEvent extends TrackerEvent {
  final RecordEntity record;

  const LoadDeckFromRecordEvent({required this.record});

  @override
  List<Object> get props => [record];
}

class ResetDeckEvent extends TrackerEvent {}
