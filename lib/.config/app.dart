class AppConfig {
  // User settings
  static const String keyLocale          = 'locale';
  static const String keyIsDark          = 'isDark';

  // App state
  static const String keyIsLoggedIn      = 'isLoggedIn';
  static const String keyRecentId        = 'recentId';
  static const String keyRecentGame      = 'recentGame';
  static const String keyTutorialNFCIcon = 'tutorial_nfc_icon';

  // Default values
  static final Map<String, dynamic> defaults = {
    keyLocale:          'th',
    keyIsDark:          true,
    keyIsLoggedIn:      false,
    keyRecentId:        null,
    keyRecentGame:      null,
    keyTutorialNFCIcon: false,
  };
}
