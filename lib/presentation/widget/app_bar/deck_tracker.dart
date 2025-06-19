import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/drawer.dart';
import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader.dart';
import '../../cubit/record.dart';
import '../../cubit/tracker.dart';
import '../../cubit/usage_card.dart';
import '../../locale/localization.dart';

import '../notification/cupertino_dialog.dart';

import '@default.dart';

class DeckTrackerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final NfcCubit nfcCubit;

  const DeckTrackerAppBar({
    super.key, 
    required this.userId,
    required this.nfcCubit
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

    final drawerCubit = context.read<DrawerCubit>();
    final readerCubit = context.read<ReaderCubit>();
    final recordCubit = context.read<RecordCubit>();
    final trackerCubit = context.read<TrackerCubit>();
    final usageCardCubit = context.read<UsageCardCubit>();

    final isAdvancedMode = trackerCubit.state.isAdvancedMode;
    final isSessionActive = nfcCubit.state.isSessionActive;

    final toggleNfcItem = AppBarMenuItem(
      label: isSessionActive
          ? Icons.wifi_tethering_rounded
          : Icons.wifi_tethering_off_rounded,
      action: () {
        isSessionActive ? nfcCubit.stopSession() : nfcCubit.startSession();
      },
    );

    if (isAdvancedMode) {
      return [
        AppBarMenuItem(
          label: Icons.access_time_rounded,
          action: () => drawerCubit.toggleHistoryDrawer(),
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
                    trackerCubit.toggleResetDeck();
                    recordCubit.toggleResetRecord();
                    readerCubit.resetScannedCard();
                    usageCardCubit.resetUsageStats();
                    navigator.pop();
                  },
                ),
                DialogChoice(
                  text: locale.translate('page_deck_tracker.button_save'),
                  onPressed: () {
                    recordCubit.createRecord(userId: userId);
                    trackerCubit.toggleResetDeck();
                    recordCubit.toggleResetRecord();
                    readerCubit.resetScannedCard();
                    usageCardCubit.resetUsageStats();
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
          action: () => trackerCubit.toggleAdvancedMode(),
        ),
      ];
    } else {
      return [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.people_rounded,
          action: () => userId.isEmpty 
              ? buildCupertinoAlertDialog(
                  theme: Theme.of(context),
                  title: locale.translate('page_deck_tracker.dialog_room_feature_title'),
                  content: locale.translate('page_deck_tracker.dialog_room_feature_content'),
                  confirmButtonText: locale.translate('common.button_ok'),
                  onPressed: () {},
                  closeDialog: () => navigator.pop(),
                  showDialog: (dialog) => showCupertinoDialog(
                    context: context,
                    builder: (_) => dialog,
                  ),
                ) 
              : drawerCubit.toggleFeatureDrawer(),
        ),
        AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
        toggleNfcItem,
        AppBarMenuItem(
          label: Icons.build_outlined,
          action: () {
            trackerCubit.toggleAdvancedMode();
            if (drawerCubit.state.visibleFeatureDrawer) {
              drawerCubit.toggleFeatureDrawer();
            }
          },
        ),
      ];
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
