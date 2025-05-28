import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/application_cubit.dart';
import '../locale/language_manager.dart';
import '../locale/localization.dart';
import '../widget/material/setting_constant.dart';
import '../widget/shared/app_bar.dart';
import '../widget/specific/language_list_view.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final applicationCubit = context.read<ApplicationCubit>();

    final languageCode = locale.locale.languageCode;
    final languageItems = LanguageManager.languageNames.entries.map((entry) {
      final code = entry.key;
      final name = entry.value;

      return {
        'text': name,
        'onTap': () {
          applicationCubit.updateSetting(
            key: SettingConstant.keylocale,
            value: code,
          );
        },
        'mark': code == languageCode,
      };
    }).toList();

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_language.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: LanguageListViewWidget(
        language: [
          {
            'content': languageItems,
          }
        ],
      ),
    );
  }
}
