part of 'bloc.dart';

class ApplicationState extends Equatable {
  final AppSettings settings;
  final SessionUser? user;
  final bool isOnline;
  final int currentPageIndex;
  final String errorMessage;

  const ApplicationState({
    this.settings = const AppSettings(),
    this.user,
    this.isOnline = false,
    this.currentPageIndex = RouteConstant.on_boarding_index,
    this.errorMessage = '',
  });

  bool get isSignedIn => user != null || settings.isGuest;

  Locale get locale => Locale(settings.locale);
  bool get isDark => settings.isDark;
  String? get guestId => settings.guestId;
  String? get recentId => settings.recentId;
  String? get recentGame => settings.recentGame;
  bool get tutorialNfcIcon => settings.showNfcTutorial;

  ApplicationState copyWith({
    AppSettings? settings,
    SessionUser? user,
    bool clearUser = false,
    bool? isOnline,
    int? currentPageIndex,
    String? errorMessage,
  }) {
    return ApplicationState(
      settings: settings ?? this.settings,
      user: clearUser ? null : user ?? this.user,
      isOnline: isOnline ?? this.isOnline,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [settings, user, isOnline, currentPageIndex, errorMessage];
}
