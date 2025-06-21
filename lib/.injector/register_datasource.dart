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
    _roomRemoteDatasource();
    _uploadImageRemoteDatasource();

    LoggerUtil.debugMessage('✔️ DataSource registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register datasource: $e');
  }
}

void _serviceFactoryRemoteDatasource() {
  locator.registerFactoryParam<GameApi, String, void>((collectionId, _) {
    return ServiceFactory.create(collectionId);
  });
}

void _cardLocalDatasource() {
  locator.registerLazySingleton(() => CheckCardDuplicateNameLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => CreateCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchUsedCardDistinctLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FindCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => SaveCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateCardLocalDatasource(locator<SQLiteService>()));
}

void _collectionLocalDatasource() {
  locator.registerLazySingleton(() => CreateCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateCollectionDateLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateCollectionLocalDatasource(locator<SQLiteService>()));
}

void _deckLocalDatasource() {
  locator.registerLazySingleton(() => CreateDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchCardInDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateDeckLocalDatasource(locator<SQLiteService>()));
}

void _localDatasource() {
  locator.registerLazySingleton(() => ClearUserDataLocalDatasource(locator<SQLiteService>()));
}

void _pageLocalDatasource() {
  locator.registerLazySingleton(() => CreatePageLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FindPageLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdatePageLocalDatasource(locator<SQLiteService>()));
}

void _recordLocalDatasource() {
  locator.registerLazySingleton(() => CreateRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateRecordLocalDatasource(locator<SQLiteService>()));
}

void _settingLocalDatasource() {
  locator.registerLazySingleton(() => LoadSettingLocalDatasource(locator<SharedPreferencesService>()));
  locator.registerLazySingleton(() => SaveSettingLocalDatasource(locator<SharedPreferencesService>()));
}

void _cardRemoteDatasource() {
  locator.registerLazySingleton(() => CreateCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateCardRemoteDatasource(locator<FirestoreService>()));
}

void _collectionRemoteDatasource() {
  locator.registerLazySingleton(() => CreateCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateCollectionRemoteDatasource(locator<FirestoreService>()));
}

void _deckRemoteDatasource() {
  locator.registerLazySingleton(() => CreateDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateDeckRemoteDatasource(locator<FirestoreService>()));
}

void _recordRemoteDatasource() {
  locator.registerLazySingleton(() => CreateRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateRecordRemoteDatasource(locator<FirestoreService>()));
}

void _roomRemoteDatasource() {
  locator.registerLazySingleton(() => CreateRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => JoinRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => CloseRoomRemoteDatasource(locator<FirestoreService>()));
}

void _uploadImageRemoteDatasource() {
  locator.registerLazySingleton(() => UploadImageRemoteDatasource(locator<SupabaseService>()));
}
