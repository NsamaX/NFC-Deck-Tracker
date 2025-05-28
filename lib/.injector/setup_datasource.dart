import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/api/_service_factory.dart';

import 'package:nfc_deck_tracker/data/datasource/local/_index.dart';
import 'package:nfc_deck_tracker/data/datasource/local/_shared_preferences_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/_sqlite_service.dart';

import 'package:nfc_deck_tracker/data/datasource/remote/_firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/_index.dart';

import 'setup_locator.dart';

Future<void> setupDataSource() async {
  try {
    // API
    setupServiceFactoryRemoteDatasource();

    // Local
    setupCardLocalDatasource();
    setupCollectionLocalDatasource();
    setupDeckLocalDatasource();
    setupLocalDatasource();
    setupPageLocalDatasource();
    setupRecordLocalDatasource();
    setupSettingLocalDatasource();

    // Remote
    setupCardRemoteDatasource();
    setupCollectionRemoteDatasource();
    setupDeckRemoteDatasource();
    setupRecordRemoteDatasource();
    setupRoomRemoteDatasource();
    setupUploadImageRemoteDatasource();

    debugPrint('✔️ DataSource registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register DataSource: $e');
  }
}

// API Factory
void setupServiceFactoryRemoteDatasource() {
  locator.registerFactoryParam<GameApi, String, void>((collectionId, _) {
    return ServiceFactory.create(collectionId: collectionId);
  });
}

// ----------------- Local DataSources -----------------

void setupCardLocalDatasource() {
  locator.registerLazySingleton(() => CreateCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchUsedCardDistinctLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FindCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => SaveCardLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateCardLocalDatasource(locator<SQLiteService>()));
}

void setupCollectionLocalDatasource() {
  locator.registerLazySingleton(() => CreateCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchCollectionLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateCollectionLocalDatasource(locator<SQLiteService>()));
}

void setupDeckLocalDatasource() {
  locator.registerLazySingleton(() => CreateDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchDeckLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateDeckLocalDatasource(locator<SQLiteService>()));
}

void setupLocalDatasource() {
  locator.registerLazySingleton(() => ClearLocalDatasource(locator<SQLiteService>()));
}

void setupPageLocalDatasource() {
  locator.registerLazySingleton(() => CreatePageLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FindPageLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdatePageLocalDatasource(locator<SQLiteService>()));
}

void setupRecordLocalDatasource() {
  locator.registerLazySingleton(() => CreateRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => DeleteRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => FetchRecordLocalDatasource(locator<SQLiteService>()));
  locator.registerLazySingleton(() => UpdateRecordLocalDatasource(locator<SQLiteService>()));
}

void setupSettingLocalDatasource() {
  locator.registerLazySingleton(() => LoadSettingLocalDatasource(locator<SharedPreferencesService>()));
  locator.registerLazySingleton(() => SaveSettingLocalDatasource(locator<SharedPreferencesService>()));
}

// ----------------- Remote DataSources -----------------

void setupCardRemoteDatasource() {
  locator.registerLazySingleton(() => CreateCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchCardRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateCardRemoteDatasource(locator<FirestoreService>()));
}

void setupCollectionRemoteDatasource() {
  locator.registerLazySingleton(() => CreateCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchCollectionRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateCollectionRemoteDatasource(locator<FirestoreService>()));
}

void setupDeckRemoteDatasource() {
  locator.registerLazySingleton(() => CreateDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchDeckRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateDeckRemoteDatasource(locator<FirestoreService>()));
}

void setupRecordRemoteDatasource() {
  locator.registerLazySingleton(() => CreateRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => DeleteRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchRecordRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateRecordRemoteDatasource(locator<FirestoreService>()));
}

void setupRoomRemoteDatasource() {
  locator.registerLazySingleton(() => CreateRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => FetchRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => JoinRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => UpdateRoomRemoteDatasource(locator<FirestoreService>()));
  locator.registerLazySingleton(() => CloseRoomRemoteDatasource(locator<FirestoreService>()));
}

void setupUploadImageRemoteDatasource() {
  locator.registerLazySingleton(() => UploadImageRemoteDatasource(locator<FirestoreService>()));
}
