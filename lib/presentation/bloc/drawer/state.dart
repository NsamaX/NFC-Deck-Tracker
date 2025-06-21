part of 'bloc.dart';

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
