class AppConfig {

  static const String keyLocale     = 'locale';
  static const String keyIsDark     = 'isDark';

  static const String keyTutorial   = 'tutorial';
  static const String keyGuestId    = 'guestId';
  static const String keyRecentId   = 'recentId';
  static const String keyRecentGame = 'recentGame';

  static final Map<String, dynamic> defaults = {
    keyLocale:     'th',
    keyIsDark:     true,
    keyTutorial:   true,
    keyGuestId:    null,
    keyRecentId:   null,
    keyRecentGame: null,
  };

  static const List<String> ignoreDefaultWriteKeys = [
    keyTutorial,
    keyGuestId,
    keyRecentId,
    keyRecentGame,
  ];
}
