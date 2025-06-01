import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '../cubit/card_cubit.dart';
import '../cubit/collection_cubit.dart';
import '../cubit/search_cubit.dart';
import '../page/_index.dart';

import 'route_constant.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstant.landing:      return _build(page: const LandingPage(), settings: settings);
      case RouteConstant.sign_in:      return _build(page: const SignInPage(), settings: settings);

      case RouteConstant.my_deck:      return _build(page: const MyDeckPage(), settings: settings);
      case RouteConstant.deck_builder: return _build(page: const DeckBuilderPage(), settings: settings);
      case RouteConstant.deck_tracker: return _build(page: const DeckTrackerPage(),settings: settings);

      case RouteConstant.tag_reader:   return _build(page: const TagReaderPage(), settings: settings);
      case RouteConstant.collection:   
        return _build(
          page: BlocProvider.value(
            value: locator<CollectionCubit>(),
            child: CollectionPage(),
          ), 
          settings: settings,
        );
      case RouteConstant.browse_card:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final collectionId = args['collectionId'] ?? GameConstant.dummy;

        return _build(
          page: MultiBlocProvider(
            providers: [
              BlocProvider<CardCubit>(
                create: (_) => locator<CardCubit>(),
              ),
              BlocProvider<SearchCubit>(
                create: (_) => locator<SearchCubit>(param1: GameConstant.isSupported(collectionId) ? collectionId : GameConstant.dummy),
              ),
            ],
            child: const BrowseCardPage(),
          ),
          settings: settings,
        );
      case RouteConstant.card:         return _build(page: CardPage(), settings: settings);

      case RouteConstant.setting:      return _build(page: const SettingPage(), settings: settings);
      case RouteConstant.library:      return _build(page: const LibraryPage(), settings: settings);
      case RouteConstant.about:        return _build(page: const AboutPage(), settings: settings);
      case RouteConstant.privacy:      return _build(page: const PrivacyPage(), settings: settings);
      case RouteConstant.terms_of_use: return _build(page: const TermsOfUsePage(), settings: settings);
      case RouteConstant.language:     return _build(page: const LanguagePage(), settings: settings);

      default: return _build(page: const PageNotFound(), settings: settings);
    }
  }

  static String getInitialRoute({
    required bool loggedIn,
  }) {
    return loggedIn ? RouteConstant.on_boarding_route : RouteConstant.landing;
  }

  static MaterialPageRoute _build({
    required Widget page,
    required RouteSettings settings,
  }) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
