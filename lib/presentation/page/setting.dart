import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/specific/setting_builder.dart';
import '../widget/specific/setting_section.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final sectionBuilder = SettingsSectionBuilder(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBarWidget(
            menu: [
              AppBarMenuItem(
                label: locale.translate('page_setting.app_bar'),
              ),
            ],
          ),
          body: SettingSection(
            section: [
              sectionBuilder.buildAccountSection(user: snapshot.data),
              sectionBuilder.buildGeneralSection(),
              sectionBuilder.buildSupportSection(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(),
        );
      },
    );
  }
}
