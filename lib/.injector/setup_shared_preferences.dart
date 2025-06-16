import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/data/datasource/local/@shared_preferences_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupSharedPreferences() async {
  try {
    locator.registerSingletonAsync<SharedPreferencesService>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return SharedPreferencesService(sharedPreferences);
    });

    LoggerUtil.debugMessage(message: '✔️ SharedPreferences registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register SharedPreferences: $e');
  }
}
