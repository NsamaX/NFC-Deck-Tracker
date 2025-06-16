import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class AppLocalization {
  static const String _localePath = 'assets/locale';

  final Locale locale;
  final Map<String, dynamic> _localizedStrings = {};

  AppLocalization(this.locale);

  Future<void> load() async {
    try {
      final String jsonString = await rootBundle.loadString(
        '$_localePath/${locale.languageCode}.json',
      );

      _localizedStrings.addAll(json.decode(jsonString));

      LoggerUtil.debugMessage(message: '🔄 Localization loaded: ${locale.languageCode}');
    } catch (e) {
      _localizedStrings.clear();
      LoggerUtil.debugMessage(message: '❌ Failed to load localization: $e');
    }
  }

  String translate(
    String key,
  ) {
    try {
      final String result = key.split('.').fold<dynamic>(
        _localizedStrings,
        (value, k) {
          if (value is Map<String, dynamic> && value.containsKey(k)) {
            return value[k];
          }

          return '[Missing: $key]';
        },
      ).toString();

      if (result.startsWith('[Missing')) {
        LoggerUtil.debugMessage(message: '❗ Key not found: "$key"');
      }

      return result;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Translation error: $e');
      return '[Error: $key]';
    }
  }

  static AppLocalization of(
    BuildContext context,
  ) =>
      Localizations.of<AppLocalization>(
        context,
        AppLocalization,
      )!;
}
