class App {
  // User settings
  static const String keyLocale           = 'locale';
  static const String keyIsDark           = 'isDark';
  static const String keyIsLoggedIn       = 'isLoggedIn';

  // Recently selected data
  static const String keyRecentId         = 'recentId';
  static const String keyRecentGame       = 'recentGame';

  // In-app tutorials
  static const String keyTutorialWriteNFC = 'tutorialWriteNFC';
  static const String keyTutorialReadNFC  = 'tutorialReadNFC';

  static final Map<String, dynamic> all = {
    keyLocale:           'th',
    keyIsDark:           true,
    keyIsLoggedIn:       false,
    keyRecentId:         null,
    keyRecentGame:       null,
    keyTutorialWriteNFC: false,
    keyTutorialReadNFC:  false,
  };
}
