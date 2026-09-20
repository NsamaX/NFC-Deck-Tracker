import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/value/player_action.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck_builder/bloc.dart';
import 'package:nfc_deck_tracker/presentation/route/constant.dart';

import 'support/test_app.dart';

const collection = CollectionEntity(collectionId: 'col', name: 'MyCards');
const dragon = CardEntity(
  collectionId: 'col',
  cardId: 'dragon',
  name: 'Dragon',
  description: 'Breathes fire',
  imageUrl: '/tmp/dragon.png',
);

DataEntity take(String tag) => DataEntity(
      tagId: tag,
      collectionId: 'col',
      cardId: 'dragon',
      location: 'hand',
      playerAction: PlayerAction.take,
      timestamp: DateTime(2026, 9, 20, 9),
    );

void main() {
  setUpAll(initTestConfig);

  // Blocs must be created inside the test body so their handlers run in the
  // test's fake-async zone.
  TestWorld makeWorld() => TestWorld()
    ..collections.local['col'] = collection
    ..cards.local['dragon'] = dragon;

  testWidgets('building a deck: new deck, add a card, save, reopen and rename',
      (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.my_deck);
    expect(find.text("Tap the '+' icon to create a new deck."), findsOneWidget);

    await tester.tap(find.byIcon(Icons.open_in_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('New Deck'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MyCards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dragon'));
    await tester.pumpAndSettle();
    expect(find.text('Card Info'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(
        world.dependencies.deckBuilderBloc.state.currentDeck.cards.single.count,
        2);

    // Add pops the card page itself, so one back returns to the builder.
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Total 2 Cards'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(world.decks.local.length, 1);
    final deckId = world.decks.local.keys.single;

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('New Deck'), findsOneWidget);

    await tester.tap(find.text('New Deck'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Renamed Deck');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(world.decks.local[deckId]!.name, 'Renamed Deck');
    expect(world.dependencies.deckBuilderBloc.state.isEditMode, isFalse);
  });

  testWidgets('editing a custom card keeps the typed description',
      (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.collection);
    await tester.tap(find.text('MyCards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dragon'));
    await tester.pumpAndSettle();
    expect(find.text('Custom Card'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Breathes fire'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Breathes fire'), 'Edited desc');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(world.cards.local['dragon']!.description, 'Edited desc');
    expect(world.cards.local['dragon']!.imageUrl, dragon.imageUrl);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Edited desc'), findsOneWidget);
  });

  testWidgets('creating a custom card stores the typed description',
      (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.collection);
    await tester.tap(find.text('MyCards'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload Image'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Knight');
    await tester.enterText(fields.at(1), 'Has description');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create').last);
    await tester.pumpAndSettle();

    final created =
        world.cards.local.values.firstWhere((c) => c.name == 'Knight');
    expect(created.description, 'Has description');
    expect(created.imageUrl, world.device.nextImagePath);
  });

  testWidgets('selecting a history record shows that record\'s summary',
      (tester) async {
    final world = makeWorld();
    const deck = DeckEntity(
      deckId: 'deck',
      name: 'Deck',
      cards: [CardInDeckEntity(card: dragon, count: 2)],
    );
    world.decks.local['deck'] = deck;
    world.records.local['r1'] = RecordEntity(
        deckId: 'deck',
        recordId: 'r1',
        data: [take('t1')],
        createdAt: DateTime(2026, 9, 20, 9));
    world.records.local['r2'] = RecordEntity(
        deckId: 'deck',
        recordId: 'r2',
        data: [take('t1'), take('t2')],
        createdAt: DateTime(2026, 9, 20, 9, 30));
    world.dependencies.deckBuilderBloc.add(const OpenDeckEvent(deck: deck));
    await world.dependencies.deckBuilderBloc.stream
        .firstWhere((s) => s.currentDeck.deckId == 'deck' && !s.isLoading);

    await world.pump(tester, initialRoute: RouteConstant.deck_tracker);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Insight'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('09:00:00'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Draw 1'), findsOneWidget);
    expect(find.textContaining('50.0%'), findsOneWidget);

    await tester.tap(find.text('09:30:00'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Draw 2'), findsOneWidget);
    expect(find.textContaining('100.0%'), findsOneWidget);
  });

  testWidgets(
      'the search filter survives a refetch after returning to the list',
      (tester) async {
    final world = makeWorld();
    await world.pump(tester, initialRoute: RouteConstant.collection);
    await tester.tap(find.text('MyCards'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No cards found matching your search.'), findsOneWidget);
    expect(find.text('Dragon'), findsNothing);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'zzz'), findsOneWidget);
    expect(find.text('No cards found matching your search.'), findsOneWidget);
    expect(find.text('Dragon'), findsNothing);
  });

  testWidgets('page-scoped blocs are closed when their pages are left',
      (tester) async {
    final world = makeWorld();
    const deck = DeckEntity(deckId: 'deck', name: 'Deck');
    world.decks.local['deck'] = deck;
    world.dependencies.deckBuilderBloc.add(const OpenDeckEvent(deck: deck));
    await world.dependencies.deckBuilderBloc.stream
        .firstWhere((s) => s.currentDeck.deckId == 'deck' && !s.isLoading);

    await world.pump(tester, initialRoute: RouteConstant.deck_builder);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(world.createdBlocs.length, 4);
    expect(world.createdBlocs.every((b) => !b.isClosed), isTrue);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    // Bloc.close completes through real async work, which fake time cannot
    // advance, so let it run for real before checking.
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(world.createdBlocs.every((b) => b.isClosed), isTrue);
  });
}
