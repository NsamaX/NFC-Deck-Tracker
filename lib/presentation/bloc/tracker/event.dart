part of 'bloc.dart';

abstract class TrackerEvent extends Equatable {
  const TrackerEvent();

  @override
  List<Object?> get props => [];
}

class HandleTagScanEvent extends TrackerEvent {
  final TagEntity tag;

  const HandleTagScanEvent({required this.tag});

  @override
  List<Object?> get props => [tag];
}

class ShowAlertDialogEvent extends TrackerEvent {}

class ToggleAdvancedModeEvent extends TrackerEvent {}

class ToggleAnalysisModeEvent extends TrackerEvent {}

class ResetDeckEvent extends TrackerEvent {}
