import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class LanguageManager {
  static const String _localePath = 'assets/locale';

  static late final UnmodifiableListView<String> supportedLanguages;
  static late final UnmodifiableMapView<String, String> languageNames;

  static Future<void> initialize() async {
    try {
      final languageCodes = await _discoverLanguageCodes();
      if (languageCodes.isEmpty) {
        supportedLanguages = UnmodifiableListView([]);
        languageNames = UnmodifiableMapView({});
        LoggerUtil.w('⚠️ No language files found in $_localePath');
        return;
      }

      final entries = await Future.wait(
        languageCodes.map(_loadLanguageNameEntry).toList(),
      );

      supportedLanguages = UnmodifiableListView(languageCodes);
      languageNames = UnmodifiableMapView(Map.fromEntries(entries));

      LoggerUtil.i('💬 Supported languages loaded: ${supportedLanguages.join(", ")}');
    } on Exception catch (e) {
      supportedLanguages = UnmodifiableListView([]);
      languageNames = UnmodifiableMapView({});
      LoggerUtil.e('❌ Failed to initialize languages: $e');
    }
  }

  static Future<List<String>> _discoverLanguageCodes() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return manifestMap.keys
        .where((key) => key.startsWith('$_localePath/') && key.endsWith('.json'))
        .map((key) => key.split('/').last.split('.').first)
        .toList();
  }

  static Future<MapEntry<String, String>> _loadLanguageNameEntry(String code) async {
    try {
      final jsonString = await rootBundle.loadString('$_localePath/$code.json');
      final Map<String, dynamic> langData = json.decode(jsonString);
      final languageName = langData['language_name'] as String?;
      return MapEntry(code, languageName ?? code);
    } on Exception catch (e) {
      LoggerUtil.w('❗ Could not load name for language "$code", using code as name. Error: $e');
      return MapEntry(code, code);
    }
  }

  static String getLanguageName(String code) {
    final name = languageNames[code];
    if (name == null) {
      LoggerUtil.w('❓ Unknown language code requested: "$code"');
      return code;
    }
    return name;
  }
}
