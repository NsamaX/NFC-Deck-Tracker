class AppConfig {
  // User settings
  static const String keyLocale          = 'locale';
  static const String keyIsDark          = 'isDark';

  // App state
  static const String keyIsLoggedIn      = 'isLoggedIn';
  static const String keyRecentId        = 'recentId';
  static const String keyRecentGame      = 'recentGame';

  // In-app tutorials
  static const String keyTutorialNFCIcon = 'tutorial_nfc_icon';
  static const String keyTutorialHowTo   = 'tutorial_how_to_write_or_read';

  // Default values
  static final Map<String, dynamic> defaults = {
    locale:          'th',
    isDark:          true,
    isLoggedIn:      false,
    recentId:        null,
    recentGame:      null,
    tutorialNFCIcon: false,
    tutorialHowTo:   false,
  };
}
