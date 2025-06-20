import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import '../../auth/google.dart';
import '../../cubit/application.dart';
import '../../locale/language_manager.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

class SettingBuilder {
  final BuildContext context;
  final AppLocalization locale;
  final ApplicationCubit applicationCubit;

  SettingBuilder(this.context)
      : locale = AppLocalization.of(context),
        applicationCubit = context.read<ApplicationCubit>();

  Map<String, dynamic> buildAccountSection({User? user}) {
    return {
      'title': locale.translate('page_setting.section_account_label'),
      'content': [
        {
          'icon': Icons.account_circle_rounded,
          'text': user?.email ?? locale.translate('page_setting.section_account_email'),
        },
        {
          'icon': Icons.bookmark_added_rounded,
          'text': locale.translate('page_setting.section_account_library'),
          'route': RouteConstant.library,
        },
        {
          'icon': user == null 
              ? Icons.login_rounded 
              : Icons.logout_rounded,
          'text': user == null
              ? locale.translate('page_setting.section_account_sign_in')
              : locale.translate('page_setting.section_account_sign_out'),
          'onTap': () async {
            if (user == null) {
              await googleSignIn();
            } else {
              await googleSignOut();
              applicationCubit.clearUserData();
            }
          },
        },
      ],
    };
  }

  Map<String, dynamic> buildGeneralSection() {
    return {
      'title': locale.translate('page_setting.section_app_info_label'),
      'content': [
        {
          'icon': Icons.auto_stories_rounded,
          'text': locale.translate('page_setting.section_app_info_about'),
          'route': RouteConstant.about,
        },
        {
          'icon': Icons.privacy_tip_rounded,
          'text': locale.translate('page_setting.section_app_info_privacy'),
          'route': RouteConstant.privacy,
        },
        {
          'icon': Icons.balance_rounded,
          'text': locale.translate('page_setting.section_app_info_terms'),
          'route': RouteConstant.terms_of_use,
        },
      ],
    };
  }

  Map<String, dynamic> buildSupportSection() {
    return {
      'title': locale.translate('page_setting.section_preferences_label'),
      'content': [
        {
          'icon': Icons.language_rounded,
          'text': locale.translate('page_setting.section_preferences_language'),
          'info': LanguageManager.getLanguageName(locale.locale.languageCode),
          'route': RouteConstant.language,
        },
        {
          'icon': applicationCubit.state.isDark 
              ? Icons.dark_mode_rounded 
              : Icons.light_mode_rounded,
          'text': applicationCubit.state.isDark 
              ? locale.translate('page_setting.section_preferences_dark_mode')
              : locale.translate('page_setting.section_preferences_light_mode'),
          'onTap': () => applicationCubit.updateSetting(
            key: AppConfig.keyIsDark, 
            value: !applicationCubit.state.isDark,
          ),
        },
      ],
    };
  }
}
