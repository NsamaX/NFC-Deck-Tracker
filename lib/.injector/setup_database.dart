import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@database_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupDatabase() async {
  try {
    locator.registerLazySingleton(() => DatabaseService());

    LoggerUtil.debugMessage(message: '✔️ Database registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register Database: $e');
  }
}
