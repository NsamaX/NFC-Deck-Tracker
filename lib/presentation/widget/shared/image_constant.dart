import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

class ImageConstant {
  static final String googleLogo   = 'assets/image/google-logo.png';
  static final String internetLost = 'assets/image/internet-lost.png';
  static final String landingPage  = 'assets/image/landing-page.png';
  static final String pageNotFound = 'assets/image/page-not-found.png';

  static Map<String, String> get games {
    final Map<String, String> map = {};

    for (final String game in GameConstant.supportedGameKeys) {
      map[game] = 'assets/image/game/$game.png';
    }

    return map;
  }
}
