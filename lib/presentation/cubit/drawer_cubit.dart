import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'drawer_state.dart';

class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(const DrawerState());

  void safeEmit(DrawerState newState) {
    if (!isClosed) emit(newState);
  }

  void toggleFeatureDrawer() {
    safeEmit(state.copyWith(visibleFeatureDrawer: !state.visibleFeatureDrawer));
  }

  void toggleHistoryDrawer() {
    safeEmit(state.copyWith(visibleHistoryDrawer: !state.visibleHistoryDrawer));
  }

  void closeAllDrawer() {
    safeEmit(state.copyWith(visibleFeatureDrawer: false, visibleHistoryDrawer: false));
  }
}
