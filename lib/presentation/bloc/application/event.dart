part of 'bloc.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class InitApplicationEvent extends ApplicationEvent {}

class UpdateSettingsEvent extends ApplicationEvent {
  final AppSettings Function(AppSettings current) change;

  const UpdateSettingsEvent(this.change);
}

class SetPageIndexEvent extends ApplicationEvent {
  final int index;

  const SetPageIndexEvent({
    required this.index,
  });

  @override
  List<Object?> get props => [index];
}

class ClearUserDataEvent extends ApplicationEvent {}

class DismissApplicationErrorEvent extends ApplicationEvent {}
