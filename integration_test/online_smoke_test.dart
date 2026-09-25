import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/.config/app.dart';
import 'package:nfc_deck_tracker/main.dart' as app;
import 'package:nfc_deck_tracker/presentation/route/constant.dart';
import 'package:nfc_deck_tracker/presentation/widget/card/list_tile.dart';

/// Needs android/app/google-services.json and a filled .env. Run with
/// flutter drive --driver=test_driver/screenshots.dart
///   --target=integration_test/online_smoke_test.dart -d emulator-5554
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('online build starts and browses Scryfall', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.keyLocale, 'en');
    await prefs.remove(AppConfig.keyGuestId);

    app.main();
    Future<void> waitFor(Finder f, [int seconds = 60]) async {
      final end = DateTime.now().add(Duration(seconds: seconds));
      while (f.evaluate().isEmpty) {
        if (DateTime.now().isAfter(end)) fail('Timed out waiting for $f');
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.pumpAndSettle();
    }

    await binding.convertFlutterSurfaceToImage();
    await waitFor(find.byWidgetPredicate(
        (w) => w is Text && (w.data == 'Get Started' || w.data == 'Decks')));
    if (find.text('Get Started').evaluate().isNotEmpty) {
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('online-01-sign-in');
      await tester.tap(find.text('Continue as Guest'));
      await waitFor(find.text('Decks'));
    }
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushNamed(RouteConstant.collection);
    await waitFor(find.text('magic'));
    await binding.takeScreenshot('online-02-collections');

    await tester.tap(find.text('magic'));
    await waitFor(find.byType(CardListTile));
    // Card images come from Scryfall's CDN; give them time to load.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await binding.takeScreenshot('online-03-scryfall-browse');
  });
}
