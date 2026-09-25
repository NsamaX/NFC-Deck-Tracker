import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/index.dart';
import 'package:nfc_deck_tracker/main.dart' as app;

/// Drives the real Guest app on a device or emulator: real composition,
/// SQLite, and SharedPreferences. Run with
/// `flutter test integration_test --dart-define=GUEST_MODE=true`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out waiting for $finder');
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('a guest builds a deck, opens the tracker, and changes settings',
      (tester) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final collectionName = 'IT Cards $stamp';
    final cardName = 'IT Knight $stamp';

    app.main();
    await pumpUntil(
        tester,
        find.byWidgetPredicate((w) =>
            w is Text && (w.data == 'Get Started' || w.data == 'Decks')));
    if (find.text('Get Started').evaluate().isNotEmpty) {
      await tapAndSettle(tester, find.text('Get Started'));
      await tapAndSettle(tester, find.text('Continue as Guest'));
    }
    await pumpUntil(tester, find.text('Decks'));

    final collection = await locator<CreateCollectionUsecase>()(
        userId: '', name: collectionName);
    await locator<CreateCardUsecase>()(
        userId: '',
        card: CardEntity(
            collectionId: collection.collectionId,
            name: cardName,
            description: 'Integration test card'));

    await tapAndSettle(tester, find.byIcon(Icons.open_in_new_rounded));
    expect(find.text('New Deck'), findsOneWidget);
    await tapAndSettle(tester, find.byIcon(Icons.add_rounded));
    await pumpUntil(tester, find.text(collectionName));
    await tapAndSettle(tester, find.text(collectionName));
    await pumpUntil(tester, find.text(cardName));
    await tapAndSettle(tester, find.text(cardName));
    await tapAndSettle(tester, find.text('2'));
    await tapAndSettle(tester, find.text('Add'));
    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_ios_new_rounded));
    expect(find.text('Total: 2 cards'), findsOneWidget);

    await tapAndSettle(tester, find.text('Save'));
    final decks = await locator<FetchDeckUsecase>()(userId: '');
    final saved = decks.where(
        (d) => d.cards.any((c) => c.card.name == cardName && c.count == 2));
    expect(saved, hasLength(1), reason: 'deck saved to SQLite with its card');

    await tapAndSettle(tester, find.byIcon(Icons.play_arrow_rounded));
    await pumpUntil(tester, find.text('Deck Tracker'));
    if (find.text('OK').evaluate().isNotEmpty) {
      await tapAndSettle(tester, find.text('OK'));
    }
    expect(find.text(cardName), findsOneWidget);
    await tapAndSettle(tester, find.byIcon(Icons.wifi_tethering_off_rounded));
    await pumpUntil(tester, find.textContaining('NFC'));

    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tapAndSettle(tester, find.byIcon(Icons.arrow_back_ios_new_rounded));
    await pumpUntil(tester, find.text('Settings'));
    await tapAndSettle(tester, find.text('Settings'));

    final themeLabel = find.text('Dark Mode').evaluate().isNotEmpty
        ? 'Dark Mode'
        : 'Light Mode';
    final otherLabel = themeLabel == 'Dark Mode' ? 'Light Mode' : 'Dark Mode';
    await tapAndSettle(tester, find.text(themeLabel));
    expect(find.text(otherLabel), findsOneWidget,
        reason: 'the theme item relabels after switching');
    await tapAndSettle(tester, find.text(otherLabel));

    await tapAndSettle(tester, find.text('Language'));
    await tapAndSettle(tester, find.text('ไทย'));
    await pumpUntil(tester, find.text('ภาษา'));
    await tapAndSettle(tester, find.text('English'));
    await pumpUntil(tester, find.text('Language'));

    for (final deck in saved) {
      await locator<DeleteDeckUsecase>()(userId: '', deckId: deck.deckId);
    }
    await locator<DeleteCollectionUsecase>()(
        userId: '', collectionId: collection.collectionId);
  });
}
