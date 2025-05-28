import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LanguageManager {
  static const String _localePath = 'assets/locale';

  static late final UnmodifiableListView<String> supportedLanguages;
  static late final UnmodifiableMapView<String, String> languageNames;

  static Future<void> loadSupportedLanguages() async {
    try {
      final String manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<String> languages = manifestMap.keys
          .where((String key) => key.startsWith('$_localePath/') && key.endsWith('.json'))
          .map((String key) => key.split('/').last.split('.').first)
          .toList();

      final Map<String, String> langMap = {};

      for (String lang in languages) {
        try {
          final String jsonString = await rootBundle.loadString('$_localePath/$lang.json');
          final Map<String, dynamic> langData = json.decode(jsonString);

          langMap[lang] = langData['language_name'] ?? lang;
        } catch (e) {
          langMap[lang] = lang;
          debugPrint('❗ Failed to load language file for "$lang": $e');
        }
      }

      supportedLanguages = UnmodifiableListView(languages);
      languageNames = UnmodifiableMapView(langMap);

      debugPrint('💬 Supported languages loaded: ${supportedLanguages.join(", ")}');
    } catch (e) {
      supportedLanguages = UnmodifiableListView([]);
      languageNames = UnmodifiableMapView({});

      debugPrint('❌ Failed to load supported languages: $e');
    }
  }

  static String getLanguageName(
    String code,
  ) {
    final String name = languageNames[code] ?? '[Unknown Language]';

    if (name == '[Unknown Language]') {
      debugPrint('❓ Unknown language code: "$code"');
    }

    return name;
  }
}
