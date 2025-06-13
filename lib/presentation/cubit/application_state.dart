part of 'application_cubit.dart';

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final bool isUserLoggedIn;
  final String recentId;
  final String recentGame;
  final int currentPageIndex;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.isUserLoggedIn,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
  });

  factory ApplicationState.initialFromConstant() {
    return ApplicationState(
      locale: Locale(App.all[App.keylocale]),
      isDark: App.all[App.keyIsDark],
      isUserLoggedIn: App.all[App.keyIsUserLoggedIn],
      recentId: '',
      recentGame: '',
      currentPageIndex: RouteConstant.on_boarding_index,
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    bool? isUserLoggedIn,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      isUserLoggedIn: isUserLoggedIn ?? this.isUserLoggedIn,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        isDark,
        isUserLoggedIn,
        recentId,
        recentGame,
        currentPageIndex,
      ];
}
