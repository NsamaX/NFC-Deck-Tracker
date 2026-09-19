import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@shared_preferences_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/~index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@supabase_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerDataSource() async {
  try {
    _serviceFactoryRemoteDatasource();

    _cardLocalDatasource();
    _collectionLocalDatasource();
    _deckLocalDatasource();
    _localDatasource();
    _pageLocalDatasource();
    _recordLocalDatasource();
    _settingLocalDatasource();

    _cardRemoteDatasource();
    _collectionRemoteDatasource();
    _deckRemoteDatasource();
    _recordRemoteDatasource();

    LoggerUtil.buffer('DataSource registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('Failed to register datasource: $e');
  }
}

void _serviceFactoryRemoteDatasource() {
  locator.registerFactoryParam<GameApi, String, void>((collectionId, _) {
    return ServiceFactory.create(collectionId: collectionId);
  });
}

void _cardLocalDatasource() {
  locator.registerLazySingleton(
      () => CardLocalDatasource(locator<SQLiteService>()));
}

void _collectionLocalDatasource() {
  locator.registerLazySingleton(
      () => CollectionLocalDatasource(locator<SQLiteService>()));
}

void _deckLocalDatasource() {
  locator.registerLazySingleton(
      () => DeckLocalDatasource(locator<SQLiteService>()));
}

void _localDatasource() {
  locator.registerLazySingleton(
      () => UserDataLocalDatasource(locator<SQLiteService>()));
}

void _pageLocalDatasource() {
  locator.registerLazySingleton(
      () => PageLocalDatasource(locator<SQLiteService>()));
}

void _recordLocalDatasource() {
  locator.registerLazySingleton(
      () => RecordLocalDatasource(locator<SQLiteService>()));
}

void _settingLocalDatasource() {
  locator.registerLazySingleton(
      () => SettingsLocalDatasource(locator<SharedPreferencesService>()));
}

void _cardRemoteDatasource() {
  locator.registerLazySingleton(
      () => CardRemoteDatasource(locator<FirestoreService>()));
}

void _collectionRemoteDatasource() {
  locator.registerLazySingleton(
      () => CollectionRemoteDatasource(locator<FirestoreService>()));
}

void _deckRemoteDatasource() {
  locator.registerLazySingleton(
      () => DeckRemoteDatasource(locator<FirestoreService>()));
}

void _recordRemoteDatasource() {
  locator.registerLazySingleton(
      () => RecordRemoteDatasource(locator<FirestoreService>()));
}
