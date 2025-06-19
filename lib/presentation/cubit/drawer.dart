import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    safeEmit(state.copyWith(
      visibleFeatureDrawer: false,
      visibleHistoryDrawer: false,
    ));
  }
}

class DrawerState extends Equatable {
  final bool visibleFeatureDrawer;
  final bool visibleHistoryDrawer;

  const DrawerState({
    this.visibleFeatureDrawer = false,
    this.visibleHistoryDrawer = false,
  });

  DrawerState copyWith({
    bool? visibleFeatureDrawer,
    bool? visibleHistoryDrawer,
  }) {
    return DrawerState(
      visibleFeatureDrawer: visibleFeatureDrawer ?? this.visibleFeatureDrawer,
      visibleHistoryDrawer: visibleHistoryDrawer ?? this.visibleHistoryDrawer,
    );
  }

  @override
  List<Object> get props => [
        visibleFeatureDrawer,
        visibleHistoryDrawer,
      ];
}
