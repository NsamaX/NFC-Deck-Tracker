import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'event.dart';
part 'state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  DrawerBloc() : super(const DrawerState()) {
    on<ToggleFeatureDrawerEvent>(_onToggleFeatureDrawer);
    on<ToggleHistoryDrawerEvent>(_onToggleHistoryDrawer);
    on<CloseDrawerEvent>(_onCloseDrawer);
  }

  void _onToggleFeatureDrawer(ToggleFeatureDrawerEvent event, Emitter<DrawerState> emit) {
    emit(state.copyWith(visibleFeatureDrawer: !state.visibleFeatureDrawer));
  }

  void _onToggleHistoryDrawer(ToggleHistoryDrawerEvent event, Emitter<DrawerState> emit) {
    emit(state.copyWith(visibleHistoryDrawer: !state.visibleHistoryDrawer));
  }

  void _onCloseDrawer(CloseDrawerEvent event, Emitter<DrawerState> emit) {
    emit(state.copyWith(
      visibleFeatureDrawer: false,
      visibleHistoryDrawer: false,
    ));
  }
}
