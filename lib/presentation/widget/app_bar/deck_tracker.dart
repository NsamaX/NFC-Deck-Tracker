import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/drawer/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../locale/localization.dart';

import '../notification/cupertino_dialog.dart';

import 'default.dart';

class DeckTrackerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DeckTrackerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final navigator = Navigator.of(context);

    final drawerBloc = context.read<DrawerBloc>();
    final trackerBloc = context.read<TrackerBloc>();
    final isAdvancedMode = context.watch<TrackerBloc>().state.isAdvancedMode;
    final isSessionActive = context.watch<NfcBloc>().state.isSessionActive;

    final toggleNfcItem = AppBarMenuItem(
      label: isSessionActive
          ? Icons.wifi_tethering_rounded
          : Icons.wifi_tethering_off_rounded,
      action: MenuAction.callback(() {
        isSessionActive
            ? context.read<NfcBloc>().add(StopNfcSessionEvent())
            : context.read<NfcBloc>().add(StartNfcSessionEvent());
      }),
    );

    if (isAdvancedMode) {
      return [
        AppBarMenuItem(
          label: Icons.access_time_rounded,
          action: MenuAction.callback(
              () => drawerBloc.add(ToggleHistoryDrawerEvent())),
        ),
        AppBarMenuItem(
          label: Icons.refresh_rounded,
          action: MenuAction.callback(() {
            buildCupertinoMultipleChoicesDialog(
              theme: Theme.of(context),
              title:
                  locale.translate('page_deck_tracker.dialog_reset_deck_title'),
              content: locale
                  .translate('page_deck_tracker.dialog_reset_deck_content'),
              choices: [
                DialogChoice(
                  text: locale.translate('page_deck_tracker.button_reset'),
                  onPressed: () {
                    trackerBloc.add(ResetSessionEvent());
                    navigator.pop();
                  },
                ),
                DialogChoice(
                  text: locale.translate('page_deck_tracker.button_save'),
                  onPressed: () {
                    trackerBloc.add(SaveRecordEvent(
                        userId: PresentationScope.read(context).userId));
                    navigator.pop();
                  },
                ),
                DialogChoice(
                  text: locale.translate('common.button_cancel'),
                  isCancel: true,
                  onPressed: () => navigator.pop(),
                ),
              ],
              showDialog: (dialog) => showCupertinoDialog(
                context: navigator.context,
                builder: (_) => dialog,
              ),
            );
          }),
        ),
        AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
        toggleNfcItem,
        AppBarMenuItem(
          label: Icons.build_rounded,
          action: MenuAction.callback(
              () => trackerBloc.add(ToggleAdvancedModeEvent())),
        ),
      ];
    } else {
      return [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.people_rounded,
          action: MenuAction.callback(
              () => drawerBloc.add(ToggleFeatureDrawerEvent())),
          enabled: false,
        ),
        AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
        toggleNfcItem,
        AppBarMenuItem(
          label: Icons.build_outlined,
          action: MenuAction.callback(() {
            trackerBloc.add(ToggleAdvancedModeEvent());
            if (drawerBloc.state.visibleFeatureDrawer) {
              drawerBloc.add(ToggleFeatureDrawerEvent());
            }
          }),
        ),
      ];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
