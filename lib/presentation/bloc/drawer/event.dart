part of 'bloc.dart';

abstract class DrawerEvent extends Equatable {
  const DrawerEvent();

  @override
  List<Object?> get props => [];
}

class ToggleFeatureDrawerEvent extends DrawerEvent {}

class ToggleHistoryDrawerEvent extends DrawerEvent {}

class CloseAllDrawerEvent extends DrawerEvent {}
