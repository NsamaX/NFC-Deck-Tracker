import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../cubit/deck_cubit.dart';
import '../cubit/drawer_cubit.dart';
import '../cubit/nfc_cubit.dart';
import '../cubit/pin_color_cubit.dart';
import '../cubit/reader_cubit.dart';
import '../cubit/record_cubit.dart';
import '../cubit/tracker_cubit.dart';
import '../cubit/usage_card_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/history_drawer.dart';
import '../widget/specific/app_bar/deck_tracker_page.dart';
import '../widget/specific/create_room_drawer.dart';
import '../widget/specific/deck_insight_view.dart';
import '../widget/specific/deck_tracker_view.dart';
import '../widget/specific/deck_view_switcher.dart';
import '../widget/specific/tracker_listener.dart';

class DeckTrackerPage extends StatefulWidget {
  const DeckTrackerPage({super.key});

  @override
  State<DeckTrackerPage> createState() => _DeckTrackerPageState();
}

class _DeckTrackerPageState extends State<DeckTrackerPage> {
  late final String userId;
  late final String collectionId;
  late final DeckEntity deck;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    collectionId = Game.dummy;
    deck = context.read<DeckCubit>().state.currentDeck;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<DrawerCubit>()),
        BlocProvider(create: (_) => locator<PinColorCubit>()),
        BlocProvider(create: (_) => locator<UsageCardCubit>()),
        BlocProvider(create: (_) => locator<ReaderCubit>(param1: collectionId)),
        BlocProvider(create: (_) => locator<RecordCubit>(param1: deck.deckId)),
        BlocProvider(create: (_) => locator<TrackerCubit>(param1: deck)),
        BlocProvider(create: (_) => locator<NfcCubit>()),
      ],
      child: _DeckTrackerPageContent(userId: userId),
    );
  }
}

class _DeckTrackerPageContent extends StatelessWidget {
  final String userId;

  const _DeckTrackerPageContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    final trackerCubit = context.watch<TrackerCubit>();
    final readerCubit = context.watch<ReaderCubit>();
    final drawerCubit = context.watch<DrawerCubit>();
    final recordCubit = context.watch<RecordCubit>();
    final usageCardCubit = context.watch<UsageCardCubit>();
    final nfcCubit = context.watch<NfcCubit>();
    final locale = AppLocalization.of(context);

    return TrackerListener(
      child: Scaffold(
        appBar: AppBarDeckTrackerPage(
          locale: locale,
          theme: Theme.of(context),
          navigator: Navigator.of(context),
          drawerCubit: drawerCubit,
          nfcCubit: nfcCubit,
          readerCubit: readerCubit,
          recordCubit: recordCubit,
          trackerCubit: trackerCubit,
          usageCardCubit: usageCardCubit,
          userId: userId,
        ),
        body: GestureDetector(
          onTap: drawerCubit.closeAllDrawer,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: drawerCubit.state.visibleHistoryDrawer ||
                    drawerCubit.state.visibleFeatureDrawer,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    DeckViewSwitcherWidget(
                      isAnalyzeModeEnabled: trackerCubit.state.isAnalysisMode,
                      onSelected: (_) => trackerCubit.toggleAnalysisMode(),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: trackerCubit.state.isAnalysisMode
                          ? DeckInsightViewWidget(
                              locale: locale,
                              readerCubit: readerCubit,
                              trackerCubit: trackerCubit,
                              recordCubit: recordCubit,
                              usageCardCubit: usageCardCubit,
                              userId: userId,
                            )
                          : DeckTrackerView(
                              recordCubit: locator<RecordCubit>(
                                param1: trackerCubit.state.currentDeck.deckId,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              HistoryDrawer(
                drawerCubit: drawerCubit,
                readerCubit: readerCubit,
              ),
              CreateRoomDrawerWidget(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}
