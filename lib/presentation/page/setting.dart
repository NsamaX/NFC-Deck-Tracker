import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/application_cubit.dart';
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
    final auth = FirebaseAuth.instance;
    final applicationCubit = context.read<ApplicationCubit>();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        final sectionBuilder = SettingBuilder(
          locale: locale,
          applicationCubit: applicationCubit,
          user: snapshot.data,
        );

        return Scaffold(
          appBar: AppBarWidget(
            menu: [
              AppBarMenuItem(
                label: locale.translate('page_setting.app_bar'),
              ),
            ],
          ),
          body: SettingsSectionWidget(
            section: [
              sectionBuilder.buildAccountSection(),
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
