import 'package:flutter/material.dart';
import 'package:nfc_deck_tracker/domain/entity/session_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/application/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/default.dart';
import '../widget/setting/builder.dart';
import '../widget/setting/section.dart';
import '../widget/shared/bottom_navigation_bar.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final sectionBuilder = SettingBuilder(context);

    return BlocSelector<ApplicationBloc, ApplicationState, SessionUser?>(
      selector: (state) => state.user,
      builder: (context, user) {
        return Scaffold(
          appBar: DefaultAppBar(
            menu: [
              AppBarMenuItem(
                label: locale.translate('page_setting.app_bar'),
              ),
            ],
          ),
          body: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return SettingSection(
                section: [
                  sectionBuilder.buildAccountSection(user: user),
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
