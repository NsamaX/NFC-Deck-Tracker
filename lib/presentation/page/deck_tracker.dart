import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '../cubit/deck_cubit.dart';
import '../cubit/drawer_cubit.dart';
import '../cubit/pin_color_cubit.dart';
import '../cubit/reader_cubit.dart';
import '../cubit/record_cubit.dart';
import '../cubit/tracker_cubit.dart';
import '../cubit/usage_card_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/cupertino_dialog.dart';
import '../widget/shared/history_drawer.dart';
import '../widget/specific/app_bar/deck_tracker_page.dart';
import '../widget/specific/create_room_drawer.dart';
import '../widget/specific/deck_insight_view.dart';
import '../widget/specific/deck_tracker_view.dart';
import '../widget/specific/deck_view_switcher.dart';
import '../widget/specific/tracker_listener.dart';

class DeckTrackerPage extends StatelessWidget {
  const DeckTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    String _collectionId = GameConstant.dummy;
    final deck = context.read<DeckCubit>().state.currentDeck;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<DrawerCubit>()),
        BlocProvider.value(value: locator<PinColorCubit>()),
        BlocProvider(
          create: (_) => locator<UsageCardCubit>(),
        ),
        BlocProvider(
          create: (_) => locator<ReaderCubit>(param1: _collectionId),
        ),
        BlocProvider(
          create: (_) => locator<RecordCubit>(param1: deck.deckId),
        ),
        BlocProvider.value(value: locator<TrackerCubit>(param1: deck)),
      ],
      child: _DeckTrackerPageContent(),
    );
  }
}

class _DeckTrackerPageContent extends StatefulWidget {
  const _DeckTrackerPageContent();

  @override
  State<_DeckTrackerPageContent> createState() => _DeckTrackerPageContentState();
}

class _DeckTrackerPageContentState extends State<_DeckTrackerPageContent> {
  late final String userId;
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;

      final locale = AppLocalization.of(context);
      userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      context.read<TrackerCubit>().showAlertDialog();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        buildCupertinoAlertDialog(
          title: locale.translate('page_deck_tracker.dialog_tracker_tutorial_title'),
          content: locale.translate('page_deck_tracker.dialog_tracker_tutorial_content'),
          onPressed: () {},
          confirmButtonText: locale.translate('common.button_ok'),
          closeDialog: () => Navigator.of(context).pop(),
          showDialog: (dialog) => showCupertinoDialog(
            context: context,
            builder: (_) => dialog,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TrackerListener(
      child: BlocBuilder<TrackerCubit, TrackerState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBarDeckTrackerPage(userId: userId),
            body: GestureDetector(
              onTap: context.read<DrawerCubit>().closeAllDrawer,
              behavior: HitTestBehavior.opaque,
              child: BlocBuilder<DrawerCubit, DrawerState>(
                builder: (context, drawerState) {
                  final isDrawerOpen = drawerState.visibleHistoryDrawer;
                  final isFeatureOpen = drawerState.visibleFeatureDrawer;

                  return Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: isDrawerOpen || isFeatureOpen,
                        child: Column(
                          children: [
                            const SizedBox(height: 16.0),
                            DeckViewSwitcherWidget(
                              isAnalyzeModeEnabled: state.isAnalysisMode,
                              onSelected: (_) {
                                context.read<TrackerCubit>().toggleAnalysisMode();
                              },
                            ),
                            const SizedBox(height: 8.0),
                            Expanded(
                              child: state.isAnalysisMode
                                  ? const DeckInsightViewWidget()
                                  : DeckTrackerView(recordCubit: locator<RecordCubit>(param1: state.currentDeck.deckId)),
                            ),
                          ],
                        ),
                      ),
                      HistoryDrawer(
                        isOpen: context.watch<DrawerCubit>().state.visibleHistoryDrawer,
                        cards: context.watch<ReaderCubit>().state.scannedCards,
                      ),
                      const CreateRoomDrawerWidget(),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
