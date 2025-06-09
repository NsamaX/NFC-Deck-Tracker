import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '@default.dart';

import '../notification/cupertino_dialog.dart';

import '../../cubit/drawer_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../cubit/usage_card_cubit.dart';
import '../../locale/localization.dart';

class DeckTrackerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;

  const DeckTrackerAppBar({super.key, required this.userId});

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
    final nfcCubit = context.read<NfcCubit>();
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
          action: () => _showResetDialog(
            context: context,
            locale: locale,
            navigator: navigator,
            trackerCubit: trackerCubit,
            recordCubit: recordCubit,
            readerCubit: readerCubit,
            usageCardCubit: usageCardCubit,
          ),
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
          action: () => drawerCubit.toggleFeatureDrawer(),
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

  void _showResetDialog({
    required BuildContext context,
    required AppLocalization locale,
    required NavigatorState navigator,
    required TrackerCubit trackerCubit,
    required RecordCubit recordCubit,
    required ReaderCubit readerCubit,
    required UsageCardCubit usageCardCubit,
  }) {
    buildCupertinoMultipleChoicesDialog(
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
            readerCubit.resetScannedCard();
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
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
