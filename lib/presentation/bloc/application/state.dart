part of 'bloc.dart';

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final String? guestId;
  final String? recentId;
  final String? recentGame;
  final int currentPageIndex;
  final bool tutorialNfcIcon;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.guestId,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
    required this.tutorialNfcIcon,
  });

  factory ApplicationState.initial() {
    return ApplicationState(
      locale: Locale(AppConfig.defaults[AppConfig.keyLocale]),
      isDark: AppConfig.defaults[AppConfig.keyIsDark],
      guestId: AppConfig.defaults[AppConfig.keyGuestId],
      recentId: AppConfig.defaults[AppConfig.keyRecentId],
      recentGame: AppConfig.defaults[AppConfig.keyRecentGame],
      currentPageIndex: RouteConstant.on_boarding_index,
      tutorialNfcIcon: AppConfig.defaults[AppConfig.keyTutorial],
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    String? guestId,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
    bool? tutorialNfcIcon,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      guestId: guestId ?? this.guestId,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      tutorialNfcIcon: tutorialNfcIcon ?? this.tutorialNfcIcon,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        isDark,
        guestId,
        recentId,
        recentGame,
        currentPageIndex,
        tutorialNfcIcon,
      ];
}
