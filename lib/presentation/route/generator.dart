import 'package:flutter/material.dart';

import '../page/~index.dart';

import 'constant.dart';

class RouteGenerator {
  static final Map<String, WidgetBuilder> _routes = {
    RouteConstant.landing:      (_) => const LandingPage(),
    RouteConstant.sign_in:      (_) => const SignInPage(),
    RouteConstant.my_deck:      (_) => const MyDeckPage(),
    RouteConstant.deck_builder: (_) => const DeckBuilderPage(),
    RouteConstant.deck_tracker: (_) => const DeckTrackerPage(),
    RouteConstant.tag_reader:   (_) => const TagReaderPage(),
    RouteConstant.collection:   (_) => const CollectionPage(),
    RouteConstant.browse_card:  (_) => const BrowseCardPage(),
    RouteConstant.card:         (_) => const CardPage(),
    RouteConstant.setting:      (_) => const SettingPage(),
    RouteConstant.library:      (_) => const LibraryPage(),
    RouteConstant.about:        (_) => const AboutPage(),
    RouteConstant.privacy:      (_) => const PrivacyPage(),
    RouteConstant.terms_of_use: (_) => const TermsOfUsePage(),
    RouteConstant.language:     (_) => const LanguagePage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final pageBuilder = _routes[settings.name] ?? (_) => const PageNotFound();
    return MaterialPageRoute(
      builder: pageBuilder,
      settings: settings,
    );
  }

  static String getInitialRoute({required bool loggedIn}) {
    return loggedIn ? RouteConstant.on_boarding_route : RouteConstant.landing;
  }
}
