import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'language_manager.dart';
import 'localization.dart';

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(
    Locale locale,
  ) {
    final bool isSupported = LanguageManager.supportedLanguages.contains(locale.languageCode);

    if (!isSupported) {
      LoggerUtil.debugMessage('🚫 Unsupported locale: ${locale.languageCode}');
    }

    return isSupported;
  }

  @override
  Future<AppLocalization> load(
    Locale locale,
  ) async {
    final AppLocalization localizations = AppLocalization(locale);

    await localizations.load();

    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalization> old) => false;
}
