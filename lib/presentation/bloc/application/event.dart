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

class SessionChangedEvent extends ApplicationEvent {
  final SessionUser? user;

  const SessionChangedEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class ConnectivityChangedEvent extends ApplicationEvent {
  final bool isOnline;

  const ConnectivityChangedEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class DismissApplicationErrorEvent extends ApplicationEvent {}
