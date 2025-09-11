class AppConfig {
  // User settings
  static const String keyLocale     = 'locale';
  static const String keyIsDark     = 'isDark';

  // App state
  static const String keyTutorial   = 'tutorial';
  static const String keyGuestId    = 'guestId';
  static const String keyRecentId   = 'recentId';
  static const String keyRecentGame = 'recentGame';

  // Default values
  static final Map<String, dynamic> defaults = {
    keyLocale:     'th',
    keyIsDark:     true,
    keyTutorial:   true,
    keyGuestId:    null,
    keyRecentId:   null,
    keyRecentGame: null,
  };

  // Keys that should not be written with default value
  static const List<String> ignoreDefaultWriteKeys = [
    keyTutorial,
    keyGuestId,
    keyRecentId,
    keyRecentGame,
  ];
}
