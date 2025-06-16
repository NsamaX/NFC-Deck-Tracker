import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/@sqlite_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupSqlite() async {
  try {
    locator.registerLazySingleton(() => SQLiteService(locator<DatabaseService>()));
    
    LoggerUtil.debugMessage(message: '✔️ SQLite registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register SQLite: $e');
  }
}
