import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/data/datasource/local/_shared_preferences_service.dart';

import 'setup_locator.dart';

Future<void> setupSharedPreferences() async {
  try {
    locator.registerSingletonAsync<SharedPreferencesService>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      return SharedPreferencesService(sharedPreferences);
    });

    debugPrint('✔️ SharedPreferences registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register SharedPreferences: $e');
  }
}
