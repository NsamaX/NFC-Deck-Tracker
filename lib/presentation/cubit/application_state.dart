part of 'application_cubit.dart';

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final bool keyIsLoggedIn;
  final String recentId;
  final String recentGame;
  final int currentPageIndex;
  final bool tutorialNfcIcon;
  final bool tutorialHowTo;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.keyIsLoggedIn,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
    required this.tutorialNfcIcon,
    required this.tutorialHowTo,
  });

  factory ApplicationState.initialFromConstant() {
    return ApplicationState(
      locale: Locale(AppConfig.defaults[AppConfig.keyLocale]),
      isDark: AppConfig.defaults[AppConfig.keyIsDark],
      keyIsLoggedIn: AppConfig.defaults[AppConfig.keyIsLoggedIn],
      recentId: '',
      recentGame: '',
      currentPageIndex: RouteConstant.on_boarding_index,
      tutorialNfcIcon: AppConfig.defaults[AppConfig.keyTutorialNFCIcon],
      tutorialHowTo: AppConfig.defaults[AppConfig.keyTutorialHowTo],
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    bool? keyIsLoggedIn,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
    bool? tutorialNfcIcon,
    bool? tutorialHowTo,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      keyIsLoggedIn: keyIsLoggedIn ?? this.keyIsLoggedIn,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      tutorialNfcIcon: tutorialNfcIcon ?? this.tutorialNfcIcon,
      tutorialHowTo: tutorialHowTo ?? this.tutorialHowTo,
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
        tutorialNfcIcon,
        tutorialHowTo,
      ];
}
