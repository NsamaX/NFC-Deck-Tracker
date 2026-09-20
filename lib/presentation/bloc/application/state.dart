part of 'bloc.dart';

class ApplicationState extends Equatable {
  final AppSettings settings;
  final int currentPageIndex;
  final String errorMessage;

  const ApplicationState({
    this.settings = const AppSettings(),
    this.currentPageIndex = RouteConstant.on_boarding_index,
    this.errorMessage = '',
  });

  Locale get locale => Locale(settings.locale);
  bool get isDark => settings.isDark;
  String? get guestId => settings.guestId;
  String? get recentId => settings.recentId;
  String? get recentGame => settings.recentGame;
  bool get tutorialNfcIcon => settings.showNfcTutorial;

  ApplicationState copyWith({
    AppSettings? settings,
    int? currentPageIndex,
    String? errorMessage,
  }) {
    return ApplicationState(
      settings: settings ?? this.settings,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [settings, currentPageIndex, errorMessage];
}
