import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@database_service.dart';

import 'setup_locator.dart';

Future<void> setupDatabase() async {
  try {
    locator.registerLazySingleton(() => DatabaseService());

    debugPrint('✔️ Database registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register Database: $e');
  }
}
