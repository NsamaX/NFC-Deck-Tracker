part of 'bloc.dart';

abstract class ApplicationEvent extends Equatable {
  const ApplicationEvent();

  @override
  List<Object?> get props => [];
}

class InitApplicationEvent extends ApplicationEvent {}

class UpdateSettingEvent extends ApplicationEvent {
  final String key;
  final dynamic value;

  const UpdateSettingEvent({
    required this.key,
    required this.value,
  });

  @override
  List<Object?> get props => [key, value];
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
