part of 'application_cubit.dart';

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final bool keyIsLoggedIn;
  final String recentId;
  final String recentGame;
  final int currentPageIndex;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.keyIsLoggedIn,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
  });

  factory ApplicationState.initialFromConstant() {
    return ApplicationState(
      locale: Locale(App.all[App.keyLocale]),
      isDark: App.all[App.keyIsDark],
      keyIsLoggedIn: App.all[App.keyIsLoggedIn],
      recentId: '',
      recentGame: '',
      currentPageIndex: RouteConstant.on_boarding_index,
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    bool? keyIsLoggedIn,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      keyIsLoggedIn: keyIsLoggedIn ?? this.keyIsLoggedIn,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        isDark,
        keyIsLoggedIn,
        recentId,
        recentGame,
        currentPageIndex,
      ];
}
