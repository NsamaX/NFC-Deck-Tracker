import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String locale;
  final bool isDark;
  final bool showNfcTutorial;
  final String? guestId;
  final String? recentId;
  final String? recentGame;

  const AppSettings({
    this.locale = 'th',
    this.isDark = true,
    this.showNfcTutorial = true,
    this.guestId,
    this.recentId,
    this.recentGame,
  });

  bool get isGuest => guestId != null;

  AppSettings copyWith({
    String? locale,
    bool? isDark,
    bool? showNfcTutorial,
    String? guestId,
    bool clearGuestId = false,
    String? recentId,
    String? recentGame,
  }) =>
      AppSettings(
        locale: locale ?? this.locale,
        isDark: isDark ?? this.isDark,
        showNfcTutorial: showNfcTutorial ?? this.showNfcTutorial,
        guestId: clearGuestId ? null : guestId ?? this.guestId,
        recentId: recentId ?? this.recentId,
        recentGame: recentGame ?? this.recentGame,
      );

  @override
  List<Object?> get props =>
      [locale, isDark, showNfcTutorial, guestId, recentId, recentGame];
}
