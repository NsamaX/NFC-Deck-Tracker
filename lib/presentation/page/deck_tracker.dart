import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '../cubit/deck_cubit.dart';
import '../cubit/drawer_cubit.dart';
import '../cubit/pin_color_cubit.dart';
import '../cubit/reader_cubit.dart';
import '../cubit/record_cubit.dart';
import '../cubit/tracker_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/cupertino_dialog.dart';
import '../widget/shared/history_drawer.dart';
import '../widget/specific/app_bar_deck_tracker_page.dart';
import '../widget/specific/create_room_drawer.dart';
import '../widget/specific/deck_insight_view_new.dart';
import '../widget/specific/deck_tracker_view.dart';
import '../widget/specific/deck_view_switcher.dart';
import '../widget/specific/nfc_track_listener.dart';

class DeckTrackerPage extends StatelessWidget {
  const DeckTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.read<DeckCubit>().state.currentDeck;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<DrawerCubit>()),
        BlocProvider.value(value: locator<PinColorCubit>()),
        BlocProvider.value(value: locator<RecordCubit>(param1: deck)),
        BlocProvider.value(value: locator<TrackerCubit>(param1: deck)),
        BlocProvider.value(value: locator<ReaderCubit>()),
      ],
      child: _DeckTrackerPageContent(deck: deck),
    );
  }
}

class _DeckTrackerPageContent extends StatefulWidget {
  final deck;

  const _DeckTrackerPageContent({required this.deck});

  @override
  State<_DeckTrackerPageContent> createState() => _DeckTrackerPageContentState();
}

class _DeckTrackerPageContentState extends State<_DeckTrackerPageContent> {
  late final String userId;

  @override
  void initState() {
    super.initState();

    final locale = AppLocalization.of(context);
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    context.read<RecordCubit>().fetchRecord(userId: userId,  deckId: widget.deck.deckId!);
    context.read<TrackerCubit>().showAlertDialog();

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
  }

  @override
  Widget build(BuildContext context) {
    final drawerCubit = context.read<DrawerCubit>();
    final trackerCubit = context.read<TrackerCubit>();

    return NfcTrackListener(
      child: BlocBuilder<TrackerCubit, TrackerState>(
        builder: (context, state) {
          return Scaffold(
            appBar: DeckTrackerAppBar(userId: userId),
            body: GestureDetector(
              onTap: drawerCubit.closeAllDrawer,
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
                                trackerCubit.toggleAnalysisMode();
                              },
                            ),
                            const SizedBox(height: 8.0),
                            Expanded(
                              child: state.isAnalysisMode
                                  ? const DeckInsightViewWidget()
                                  : const DeckTrackerViewWidget(),
                            ),
                          ],
                        ),
                      ),
                      const HistoryDrawerWidget(),
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
