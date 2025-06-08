import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../shared/app_bar.dart';
import '../../shared/cupertino_dialog.dart';

import '../../../cubit/drawer_cubit.dart';
import '../../../cubit/nfc_cubit.dart';
import '../../../cubit/reader_cubit.dart';
import '../../../cubit/record_cubit.dart';
import '../../../cubit/tracker_cubit.dart';
import '../../../cubit/usage_card_cubit.dart';
import '../../../locale/localization.dart';

class AppBarDeckTrackerPage extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalization locale;
  final ThemeData theme;
  final NavigatorState navigator;
  final DrawerCubit drawerCubit;
  final NfcCubit nfcCubit;
  final ReaderCubit readerCubit;
  final RecordCubit recordCubit;
  final TrackerCubit trackerCubit;
  final UsageCardCubit usageCardCubit;
  final String userId;

  const AppBarDeckTrackerPage({
    super.key,
    required this.locale,
    required this.theme,
    required this.navigator,
    required this.drawerCubit,
    required this.nfcCubit,
    required this.readerCubit,
    required this.recordCubit,
    required this.trackerCubit,
    required this.usageCardCubit,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isAdvancedMode = trackerCubit.state.isAdvancedMode;
    final menuItems = isAdvancedMode
        ? _buildAdvancedMenu()
        : _buildNormalMenu();

    return AppBarWidget(menu: menuItems);
  }

  List<AppBarMenuItem> _buildAdvancedMenu() {
    return [
      AppBarMenuItem(
        label: Icons.access_time_rounded,
        action: () => drawerCubit.toggleHistoryDrawer(),
      ),
      AppBarMenuItem(
        label: Icons.refresh_rounded,
        action: () => _showResetDialog(),
      ),
      AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
      AppBarMenuItem(
        label: nfcCubit.state.isSessionActive
            ? Icons.wifi_tethering_rounded
            : Icons.wifi_tethering_off_rounded,
        action: () {
          if (nfcCubit.state.isSessionActive) {
            nfcCubit.stopSession();
          } else {
            nfcCubit.startSession();
          }
        },
      ),
      AppBarMenuItem(
        label: Icons.build_rounded,
        action: () => trackerCubit.toggleAdvancedMode(),
      ),
    ];
  }

  List<AppBarMenuItem> _buildNormalMenu() {
    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: Icons.people_rounded,
        action: () => drawerCubit.toggleFeatureDrawer(),
      ),
      AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
      AppBarMenuItem(
        label: nfcCubit.state.isSessionActive
            ? Icons.wifi_tethering_rounded
            : Icons.wifi_tethering_off_rounded,
        action: () {
          if (nfcCubit.state.isSessionActive) {
            nfcCubit.stopSession();
          } else {
            nfcCubit.startSession();
          }
        },
      ),
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

  void _showResetDialog() {
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
