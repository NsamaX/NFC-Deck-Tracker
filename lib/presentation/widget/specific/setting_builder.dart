import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../material/google_athen.dart';

import '../../cubit/application_cubit.dart';
import '../../locale/language_manager.dart';
import '../../locale/localization.dart';
import '../../route/route.dart';

class SettingBuilder {
  final AppLocalization locale;
  final ApplicationCubit applicationCubit;
  final User? user;

  const SettingBuilder({
    required this.locale,
    required this.applicationCubit,
    required this.user,
  });

  Map<String, dynamic> buildAccountSection() {
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
          'icon': user == null ? Icons.login_rounded : Icons.logout_rounded,
          'text': user == null
              ? locale.translate('page_setting.section_account_sign_in')
              : locale.translate('page_setting.section_account_sign_out'),
          'onTap': () async {
            if (user == null) {
              await signInWithGoogle();
            } else {
              await signOutFromGoogle(applicationCubit: applicationCubit);
            }
          },
        },
      ],
    };
  }

  Map<String, dynamic> buildGeneralSection() => {
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

  Map<String, dynamic> buildSupportSection() => {
        'title': locale.translate('page_setting.section_preferences_label'),
        'content': [
          {
            'icon': Icons.language_rounded,
            'text': locale.translate('page_setting.section_preferences_language'),
            'info': LanguageManager.getLanguageName(locale.locale.languageCode),
            'route': RouteConstant.language,
          },
        ],
      };
}
