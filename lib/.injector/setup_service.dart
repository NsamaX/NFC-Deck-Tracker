import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@shared_preferences_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@firestore_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupService() async {
  try {
    await _setupMisc();
    await _setupSharedPreferences();
    await _setupDatabase();
    await _setupSqlite();
    await _setupFirestore();

    LoggerUtil.debugMessage(message: '✔️ All services registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to setup services: $e');
  }
}

Future<void> _setupMisc() async {
  if (!locator.isRegistered<FirebaseAuth>()) {
    locator.registerLazySingleton(() => FirebaseAuth.instance);
  }
  if (!locator.isRegistered<FirebaseFirestore>()) {
    locator.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  locator.registerLazySingleton<RouteObserver<ModalRoute>>(() => RouteObserver<ModalRoute>());
}

Future<void> _setupSharedPreferences() async {
  locator.registerSingletonAsync<SharedPreferencesService>(() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesService(prefs);
  });
}

Future<void> _setupDatabase() async {
  locator.registerLazySingleton(() => DatabaseService());
}

Future<void> _setupSqlite() async {
  locator.registerLazySingleton(() => SQLiteService(locator<DatabaseService>()));
}

Future<void> _setupFirestore() async {
  locator.registerLazySingleton(() => FirestoreService(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  ));
}
