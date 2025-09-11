import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class AppLocalization {
  static const String _localePath = 'assets/locale';

  final Locale locale;
  late final Map<String, dynamic> _localizedStrings;
  bool _isLoaded = false;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) => Localizations.of<AppLocalization>(context, AppLocalization)!;

  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString('$_localePath/${locale.languageCode}.json');
      _localizedStrings = json.decode(jsonString);
      _isLoaded = true;
      LoggerUtil.i('🔄 Localization loaded: ${locale.languageCode}');
      return true;
    } on Exception catch (e) {
      _isLoaded = false;
      LoggerUtil.e('❌ Failed to load localization for ${locale.languageCode}: $e');
      return false;
    }
  }

  String translate(String key) {
    if (!_isLoaded) {
      return key;
    }

    try {
      final keyParts = key.split('.');
      dynamic currentValue = _localizedStrings;

      for (final part in keyParts) {
        if (currentValue is Map<String, dynamic> &&
            currentValue.containsKey(part)) {
          currentValue = currentValue[part];
        } else {
          LoggerUtil.w('❗ Missing translation key: "$key" in locale "${locale.languageCode}"');
          return key;
        }
      }
      return currentValue.toString();
    } on Exception catch (e) {
      LoggerUtil.e('❌ Translation error for key "$key": $e');
      return key;
    }
  }
}
