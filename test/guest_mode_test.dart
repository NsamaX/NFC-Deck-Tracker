import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/.config/api.dart';
import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.config/runtime.dart';
import 'package:nfc_deck_tracker/.injector/service_locator.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@supabase_service.dart';
import 'package:nfc_deck_tracker/presentation/auth/session.dart';
import 'package:nfc_deck_tracker/presentation/bloc/application/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/card/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/collection/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck/bloc.dart';
import 'package:nfc_deck_tracker/presentation/locale/language_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    expect(RuntimeConfig.guestMode, isTrue,
        reason: 'Run with --dart-define=GUEST_MODE=true');
    SharedPreferences.setMockInitialValues({});
    await ApiConfig.load('development');
    GameConfig.load('development');
    await initServiceLocator();
  });

  tearDownAll(() async {
    await locator.reset();
  });

  test('Guest dependencies resolve without Firebase or Supabase credentials', () async {
    expect(locator<ApplicationBloc>(), isA<ApplicationBloc>());
    expect(locator<DeckBloc>(), isA<DeckBloc>());
    expect(locator<CollectionBloc>(), isA<CollectionBloc>());
    final cardBloc = locator<CardBloc>();
    await cardBloc.close();
    expect(locator.isRegistered<FirebaseAuth>(), isFalse);
    expect(Firebase.apps, isEmpty);
    expect(AuthSession.currentUser, isNull);
    expect(await AuthSession.authStateChanges().first, isNull);
    expect(GameConfig.instance.availableGames, isEmpty);
  });

  test('Offline storage does not claim that local changes were synced', () async {
    final store = locator<FirestoreService>();
    expect(await store.queryCollection(collectionPath: 'cards'), isEmpty);
    expect(await store.getDocument(collectionPath: 'cards', documentId: '1'), isNull);
    expect(await store.insert(collectionPath: 'cards', documentId: '1', data: {}), isFalse);
    expect(await store.update(collectionPath: 'cards', documentId: '1', data: {}), isFalse);
    expect(await store.delete(collectionPath: 'cards', documentId: '1'), isFalse);
  });

  test('Guest images retain their local paths without uploading', () async {
    final images = locator<SupabaseService>();
    expect(await images.uploadImage(imagePath: '/app/cards/card.png'), '/app/cards/card.png');
    expect(await images.updateImage(oldImageUrl: '/app/cards/card.png', newImagePath: '/app/cards/new.png'), '/app/cards/new.png');
  });

  test('Bundled languages load using the current Flutter asset manifest', () async {
    await LanguageManager.initialize();
    expect(LanguageManager.supportedLanguages, containsAll(['en', 'th', 'ja']));
  });
}
