part of 'application_cubit.dart';

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final bool loggedIn;
  final String recentId;
  final String recentGame;
  final int currentPageIndex;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.loggedIn,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
  });

  factory ApplicationState.initialFromConstant() {
    return ApplicationState(
      locale: Locale(SettingConstant.all[SettingConstant.keylocale]),
      isDark: SettingConstant.all[SettingConstant.keyIsDark],
      loggedIn: SettingConstant.all[SettingConstant.keyLoggedIn],
      recentId: '',
      recentGame: '',
      currentPageIndex: RouteConstant.on_boarding_index,
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    bool? loggedIn,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      loggedIn: loggedIn ?? this.loggedIn,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        isDark,
        loggedIn,
        recentId,
        recentGame,
        currentPageIndex,
      ];
}
