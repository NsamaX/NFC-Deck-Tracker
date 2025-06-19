import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import '../cubit/application.dart';
import '../locale/language_manager.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/setting/language.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_language.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: SettingLanguage(
        language: [{
          'content': LanguageManager.languageNames.entries.map((entry) {
            final code = entry.key;
            final name = entry.value;

            return {
              'text': name,
              'onTap': () {
                context.read<ApplicationCubit>().updateSetting(
                  key: AppConfig.keyLocale,
                  value: code,
                );
              },
              'mark': code == locale.locale.languageCode,
            };
          }).toList(),
        }],
      ),
    );
  }
}
