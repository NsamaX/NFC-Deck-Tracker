import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/app_bar.dart';
import '../../shared/cupertino_dialog.dart';

import '../../../cubit/drawer_cubit.dart';
import '../../../cubit/nfc_cubit.dart';
import '../../../cubit/reader_cubit.dart';
import '../../../cubit/record_cubit.dart';
import '../../../cubit/tracker_cubit.dart';
import '../../../locale/localization.dart';

class AppBarDeckTrackerPage extends StatelessWidget implements PreferredSizeWidget {
  final String userId;

  const AppBarDeckTrackerPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isAdvancedMode = context.watch<TrackerCubit>().state.isAdvancedMode;
    final menuItems = isAdvancedMode
        ? _buildAdvancedMenu(context)
        : _buildNormalMenu(context);

    return AppBarWidget(menu: menuItems);
  }

  List<AppBarMenuItem> _buildAdvancedMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final nfcCubit = context.watch<NfcCubit>();
    final drawerCubit = context.read<DrawerCubit>();
    final trackerCubit = context.read<TrackerCubit>();

    return [
      AppBarMenuItem(
        label: Icons.access_time_rounded,
        action: () => drawerCubit.toggleHistoryDrawer(),
      ),
      AppBarMenuItem(
        label: Icons.refresh_rounded,
        action: () => _showResetDialog(context),
      ),
      AppBarMenuItem(label: locale.translate('page_deck_tracker.app_bar')),
      AppBarMenuItem(
        label: nfcCubit.state.isSessionActive
            ? Icons.wifi_tethering_rounded
            : Icons.wifi_tethering_off_rounded,
        action: () => nfcCubit.startSession(),
      ),
      AppBarMenuItem(
        label: Icons.build_rounded,
        action: () => trackerCubit.toggleAdvancedMode(),
      ),
    ];
  }

  List<AppBarMenuItem> _buildNormalMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final nfcCubit = context.watch<NfcCubit>();
    final drawerCubit = context.read<DrawerCubit>();
    final trackerCubit = context.read<TrackerCubit>();

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
        action: () => nfcCubit.startSession(),
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

  void _showResetDialog(BuildContext context) {
    final locale = AppLocalization.of(context);
    final trackerCubit = context.read<TrackerCubit>();
    final recordCubit = context.read<RecordCubit>();
    final readerCubit = context.read<ReaderCubit>();
    final navigator = Navigator.of(context);

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
      showDialog: (dialog) => showCupertinoDialog(context: context, builder: (_) => dialog),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
