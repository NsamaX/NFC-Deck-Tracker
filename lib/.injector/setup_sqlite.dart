import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/local/_database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/_sqlite_service.dart';

import 'setup_locator.dart';

Future<void> setupSqlite() async {
  try {
    locator.registerLazySingleton(() => SQLiteService(locator<DatabaseService>()));
    
    debugPrint('✔️ SQLite registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register SQLite: $e');
  }
}
