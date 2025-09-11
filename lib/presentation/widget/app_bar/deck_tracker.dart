import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/drawer/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../bloc/reader/bloc.dart';
import '../../bloc/record/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../bloc/usage_card/bloc.dart';
import '../../locale/localization.dart';

import '../notification/cupertino_dialog.dart';

import '@default.dart';

class DeckTrackerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final NfcBloc nfcBloc;

  const DeckTrackerAppBar({
    super.key, 
    required this.userId,
    required this.nfcBloc
  });

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
    final readerBloc = context.read<ReaderBloc>();
    final recordBloc = context.read<RecordBloc>();
    final trackerBloc = context.read<TrackerBloc>();
    final usageCardBloc = context.read<UsageCardBloc>();

    final isAdvancedMode = trackerBloc.state.isAdvancedMode;
    final isSessionActive = nfcBloc.state.isSessionActive;

    final toggleNfcItem = AppBarMenuItem(
      label: isSessionActive
          ? Icons.wifi_tethering_rounded
          : Icons.wifi_tethering_off_rounded,
      action: () {
        isSessionActive ? nfcBloc.add(StopNfcSessionEvent()) : nfcBloc.add(StartNfcSessionEvent());
      },
    );

    if (isAdvancedMode) {
      return [
        AppBarMenuItem(
          label: Icons.access_time_rounded,
          action: () => drawerBloc.add(ToggleHistoryDrawerEvent()),
        ),
        AppBarMenuItem(
          label: Icons.refresh_rounded,
          action: () => {
            buildCupertinoMultipleChoicesDialog(
              theme: Theme.of(context),
              title: locale.translate('page_deck_tracker.dialog_reset_deck_title'),
              content: locale.translate('page_deck_tracker.dialog_reset_deck_content'),
              choices: [
                DialogChoice(
                  text: locale.translate('page_deck_tracker.button_reset'),
                  onPressed: () {
                    trackerBloc.add(ResetDeckEvent());
                    recordBloc.add(ResetRecordEvent());
                    readerBloc.add(ResetReadedCardsEvent());
                    usageCardBloc.add(ResetUsageCardEvent());
                    navigator.pop();
                  },
                ),
                DialogChoice(
                  text: locale.translate('page_deck_tracker.button_save'),
                  onPressed: () {
                    recordBloc.add(CreateRecordEvent(userId: userId));
                    trackerBloc.add(ResetDeckEvent());
                    recordBloc.add(ResetRecordEvent());
                    readerBloc.add(ResetReadedCardsEvent());
                    usageCardBloc.add(ResetUsageCardEvent());
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
            ),
          },
        ),
        AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
        toggleNfcItem,
        AppBarMenuItem(
          label: Icons.build_rounded,
          action: () => trackerBloc.add(ToggleAdvancedModeEvent()),
        ),
      ];
    } else {
      return [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.people_rounded,
          action: () => drawerBloc.add(ToggleFeatureDrawerEvent()),
          enabled: false,
        ),
        AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
        toggleNfcItem,
        AppBarMenuItem(
          label: Icons.build_outlined,
          action: () {
            trackerBloc.add(ToggleAdvancedModeEvent());
            if (drawerBloc.state.visibleFeatureDrawer) {
              drawerBloc.add(ToggleFeatureDrawerEvent());
            }
          },
        ),
      ];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
