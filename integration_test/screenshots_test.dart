import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/.config/app.dart';
import 'package:nfc_deck_tracker/.injector/service_locator.dart';
import 'package:nfc_deck_tracker/domain/entity/nfc_result.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/main.dart' as app;
import 'package:nfc_deck_tracker/presentation/bloc/deck/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck_builder/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/nfc/bloc.dart';
import 'package:nfc_deck_tracker/presentation/route/arguments.dart';
import 'package:nfc_deck_tracker/presentation/route/constant.dart';

import 'support/mock_data.dart';

/// Seeds mock data and captures every page of the Guest app. Run through
/// the driver so the images land in .temp/screenshots:
/// flutter drive --driver=test_driver/screenshots.dart
///   --target=integration_test/screenshots_test.dart
///   -d emulator-5554 --dart-define=GUEST_MODE=true
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture every page with mock data', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyLocale, 'en');
    await prefs.setString(AppConfig.keyGuestId, 'screenshot-guest');

    app.main();
    final end = DateTime.now().add(const Duration(minutes: 1));
    while (find.text('Decks').evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) fail('The app did not start');
      await tester.pump(const Duration(milliseconds: 200));
    }

    final world = await seedMockData();
    await binding.convertFlutterSurfaceToImage();

    Future<void> settle([Duration extra = Duration.zero]) async {
      await tester.pumpAndSettle();
      if (extra > Duration.zero) {
        await tester.pump(extra);
        await tester.pumpAndSettle();
      }
    }

    var index = 0;
    Future<void> shot(String name) async {
      await settle();
      index++;
      await binding.takeScreenshot('${index.toString().padLeft(2, '0')}-$name');
    }

    NavigatorState navigator() =>
        tester.state<NavigatorState>(find.byType(Navigator).first);
    Future<void> open(String route, [Object? arguments]) async {
      navigator().pushNamed(route, arguments: arguments);
      await settle(const Duration(milliseconds: 600));
    }

    Future<void> back() async {
      navigator().pop();
      await settle();
    }

    Future<void> tap(Finder finder) async {
      await tester.tap(finder);
      await settle(const Duration(milliseconds: 400));
    }

    locator<DeckBloc>().add(const FetchDeckEvent(userId: ''));
    await settle(const Duration(seconds: 1));
    await shot('my-decks');

    await open(RouteConstant.landing);
    await shot('landing');
    await back();
    await open(RouteConstant.sign_in);
    await shot('sign-in');
    await back();

    locator<DeckBuilderBloc>().add(OpenDeckEvent(deck: world.fireDeck));
    await settle(const Duration(seconds: 1));
    await open(RouteConstant.deck_builder);
    await shot('deck-builder');
    await tap(find.text('Edit'));
    await shot('deck-builder-edit');
    locator<DeckBuilderBloc>().add(CloseEditModeEvent());
    await settle();

    await tap(find.byIcon(Icons.play_arrow_rounded));
    await settle(const Duration(seconds: 5));
    await shot('deck-tracker');
    await tap(find.text('Statistics'));
    await shot('deck-tracker-statistics');
    await tap(find.text('19:05:00'));
    await shot('deck-tracker-record');
    await tap(find.text('Deck'));
    await tap(find.byIcon(Icons.build_outlined));
    await shot('deck-tracker-advanced');
    await tap(find.byIcon(Icons.access_time_rounded));
    await shot('deck-tracker-history');
    await back();
    await back();

    await open(RouteConstant.collection);
    await shot('collections');
    await back();
    await open(
        RouteConstant.browse_card,
        BrowseCardArgs(
            collectionId: world.aetherId, collectionName: 'Aether Chronicles'));
    await shot('browse-cards');
    await back();

    final ember = world.cards['Ember Drake']!;
    await open(RouteConstant.card,
        CardArgs(collectionId: ember.collectionId, card: ember));
    await shot('card-detail');
    await back();
    await open(RouteConstant.card,
        CardArgs(collectionId: ember.collectionId, card: ember, onAdd: true));
    await shot('card-add-to-deck');
    await back();
    await open(
        RouteConstant.card,
        CardArgs(
            collectionId: ember.collectionId, card: ember, onCustom: true));
    await shot('card-edit');
    await back();
    await open(RouteConstant.card,
        CardArgs(collectionId: world.aetherId, onCustom: true));
    await shot('card-create');
    await back();

    await tap(find.text('Read Tag'));
    await shot('tag-reader');
    for (final name in ['Ember Drake', 'Tide Serpent', 'Sun Priestess']) {
      final card = world.cards[name]!;
      locator<NfcBloc>().add(NfcResultEvent(NfcResult(
        notice: NfcNotice.successReadTag,
        kind: NfcResultKind.success,
        tag: TagEntity(
            tagId: 'tag-$name',
            cardId: card.cardId,
            collectionId: card.collectionId),
      )));
      await settle(const Duration(milliseconds: 500));
    }
    await settle(const Duration(seconds: 4));
    // A successful scan opens the history drawer on its own.
    await shot('tag-reader-scanned');
    await tap(find.byIcon(Icons.history_rounded));
    await tap(find.byIcon(Icons.search_rounded));
    await shot('tag-reader-collections');
    await tap(find.byIcon(Icons.search_rounded));

    await tap(find.text('Settings'));
    await shot('settings');
    await open(RouteConstant.library);
    await settle(const Duration(seconds: 1));
    await shot('library');
    await back();
    await open(RouteConstant.language);
    await shot('language');
    await back();
    await open(RouteConstant.about);
    await shot('about');
    await back();
    await open(RouteConstant.privacy);
    await shot('privacy-policy');
    await back();
    await open(RouteConstant.terms_of_use);
    await shot('terms-of-use');
    await back();
    await open('/does-not-exist');
    await shot('page-not-found');
    await back();
  });
}
