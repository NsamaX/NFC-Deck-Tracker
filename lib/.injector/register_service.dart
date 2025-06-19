import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@shared_preferences_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@firestore_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerService() async {
  try {
    await _Misc();
    await _SharedPreferences();
    await _Database();
    await _Sqlite();
    await _Firestore();

    LoggerUtil.debugMessage(message: '✔️ All services registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to setup services: $e');
  }
}

Future<void> _Misc() async {
  if (!locator.isRegistered<FirebaseAuth>()) {
    locator.registerLazySingleton(() => FirebaseAuth.instance);
  }
  if (!locator.isRegistered<FirebaseFirestore>()) {
    locator.registerLazySingleton(() => FirebaseFirestore.instance);
  }
  locator.registerLazySingleton<RouteObserver<ModalRoute>>(() => RouteObserver<ModalRoute>());
}

Future<void> _SharedPreferences() async {
  locator.registerSingletonAsync<SharedPreferencesService>(() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesService(prefs);
  });
}

Future<void> _Database() async {
  locator.registerLazySingleton(() => DatabaseService());
}

Future<void> _Sqlite() async {
  locator.registerLazySingleton(() => SQLiteService(locator<DatabaseService>()));
}

Future<void> _Firestore() async {
  locator.registerLazySingleton(() => FirestoreService(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  ));
}
