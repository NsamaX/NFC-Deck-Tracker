import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../cubit/application.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/setting/builder.dart';
import '../widget/setting/section.dart';
import '../widget/shared/bottom_navigation_bar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final sectionBuilder = SettingBuilder(context);

    return StreamBuilder<User?>(
      stream: locator<FirebaseAuth>().authStateChanges(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: DefaultAppBar(
            menu: [
              AppBarMenuItem(
                label: locale.translate('page_setting.app_bar'),
              ),
            ],
          ),
          body: BlocBuilder<ApplicationCubit, ApplicationState>(
            builder: (context, state) {
              return SettingSection(
                section: [
                  sectionBuilder.buildAccountSection(user: snapshot.data),
                  sectionBuilder.buildGeneralSection(),
                  sectionBuilder.buildSupportSection(),
                ],
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBarWidget(),
        );
      },
    );
  }
}
