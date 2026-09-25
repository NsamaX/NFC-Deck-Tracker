import 'package:flutter/foundation.dart';

import '../.config/api.dart';

import 'package:nfc_deck_tracker/data/datasource/api/api_client.dart';
import 'package:nfc_deck_tracker/data/datasource/api/game_api_registry.dart';
import 'package:nfc_deck_tracker/data/datasource/local/shared_preferences_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/supabase_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'locator.dart';

Future<void> registerDataSource() async {
  try {
    _gameApis();

    _cardLocalDatasource();
    _collectionLocalDatasource();
    _deckLocalDatasource();
    _localDatasource();
    _pageLocalDatasource();
    _recordLocalDatasource();
    _settingLocalDatasource();
    _pendingDeleteLocalDatasource();

    _cardRemoteDatasource();
    _collectionRemoteDatasource();
    _deckRemoteDatasource();
    _recordRemoteDatasource();

    LoggerUtil.buffer('DataSource registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('Failed to register datasource: $e');
    rethrow;
  }
}

void _gameApis() {
  locator.registerLazySingleton(
      () => ApiClient(userAgent: ApiConfig.userAgent),
      dispose: (client) => client.close());
  locator.registerLazySingleton(() => GameApiRegistry(locator<ApiClient>()));
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

void _pendingDeleteLocalDatasource() {
  locator.registerLazySingleton(
      () => PendingDeleteLocalDatasource(locator<SQLiteService>()));
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
