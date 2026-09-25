import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck_builder/bloc.dart';
import 'package:nfc_deck_tracker/presentation/route/constant.dart';
import 'package:nfc_deck_tracker/presentation/widget/card/item.dart';

import 'support/test_app.dart';

const dragon = CardEntity(
  collectionId: 'col',
  cardId: 'dragon',
  name: 'Dragon',
  description: 'Breathes fire',
  imageUrl: '/tmp/dragon.png',
);
const deck = DeckEntity(
  deckId: 'deck',
  name: 'Fire',
  cards: [CardInDeckEntity(card: dragon, count: 2)],
);

void main() {
  setUpAll(initTestConfig);

  TestWorld makeWorld() => TestWorld()
    ..collections.local['col'] =
        const CollectionEntity(collectionId: 'col', name: 'MyCards')
    ..cards.local['dragon'] = dragon;

  testWidgets('a new user goes from landing to the app as a guest',
      (tester) async {
    final world = makeWorld();
    world.settings.stored = world.settings.stored.copyWith(clearGuestId: true);
    await world.pump(tester, initialRoute: RouteConstant.landing);
    expect(find.text('Deck Tracker'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Continue as Guest'));
    await world.settle(tester);
    expect(world.settings.stored.guestId, isNotEmpty);
    expect(find.text('My Decks'), findsOneWidget);
  });

  testWidgets('settings switch the theme and open the info pages',
      (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.setting);
    expect(find.text('Settings'), findsWidgets);
    expect(world.settings.stored.isDark, isTrue);

    await tester.tap(find.text('Dark Mode'));
    await world.settle(tester);
    expect(world.settings.stored.isDark, isFalse);

    for (final (item, title) in [
      ('About', 'About'),
      ('Privacy Policy', 'Privacy Policy'),
      ('Terms of Use', 'Terms of Use'),
    ]) {
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets);
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the about page shows the app version', (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.about);
    expect(find.textContaining('1.0.0-test'), findsWidgets);
  });

  testWidgets('choosing a language saves it', (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.language);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('ไทย'));
    await world.settle(tester);
    expect(world.settings.stored.locale, 'th');
  });

  testWidgets('the library shows a hint when no deck uses a card',
      (tester) async {
    final world = TestWorld();
    await world.pump(tester, initialRoute: RouteConstant.library);
    expect(find.textContaining('will appear here'), findsOneWidget);
  });

  testWidgets('the library lists the cards used in decks', (tester) async {
    final world = makeWorld()..decks.local['deck'] = deck;
    await world.pump(tester, initialRoute: RouteConstant.library);
    expect(find.byType(CardItem), findsOneWidget);
  });

  testWidgets('advanced tracking mode swaps the toolbar and pins a card',
      (tester) async {
    final world = makeWorld()..decks.local['deck'] = deck;
    world.dependencies.deckBuilderBloc.add(const OpenDeckEvent(deck: deck));
    await world.dependencies.deckBuilderBloc.stream
        .firstWhere((s) => s.currentDeck.deckId == 'deck' && !s.isLoading);

    await world.pump(tester, initialRoute: RouteConstant.deck_tracker);
    expect(find.text('NFC is not available on this device.'), findsOneWidget,
        reason: 'opening the tracker starts an NFC session right away');

    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);

    Future<void> openPins() async {
      await tester.drag(find.text('Dragon'), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    await openPins();
    await tester.tap(find.byIcon(Icons.push_pin_rounded).first);
    await tester.pumpAndSettle();
    await openPins();
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await openPins();
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.build_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.refresh_rounded), findsNothing);
  });

  testWidgets('a collection is created from the app bar and deleted by swipe',
      (tester) async {
    final world = TestWorld();
    await world.pump(tester, initialRoute: RouteConstant.collection);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'Spells');
    await tester.tap(find.text('OK'));
    await world.settle(tester);
    expect(find.text('Spells'), findsOneWidget);
    expect(world.collections.local.values.single.name, 'Spells');

    await tester.drag(find.text('Spells'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await world.settle(tester);
    expect(find.text('Spells'), findsNothing);
    expect(world.collections.local, isEmpty);
  });
}
