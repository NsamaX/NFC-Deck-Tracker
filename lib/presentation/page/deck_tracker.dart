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
import '../widget/app_bar/deck_tracker.dart';
import '../widget/deck/insight_view.dart';
import '../widget/deck/switch_mode.dart';
import '../widget/deck/tracker_view.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/create_room.dart';
import '../widget/listener/deck_tracker.dart';

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
    userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
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
    final locale = AppLocalization.of(context);

    return DeckTrackerListener(
      child: Scaffold(
        appBar: DeckTrackerAppBar(
          userId: userId,
        ),
        body: GestureDetector(
          onTap: drawerCubit.closeAllDrawer,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: drawerCubit.state.visibleHistoryDrawer || drawerCubit.state.visibleFeatureDrawer,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    DeckSwitchMode(
                      isAnalyzeModeEnabled: trackerCubit.state.isAnalysisMode,
                      onSelected: (_) => trackerCubit.toggleAnalysisMode(),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: trackerCubit.state.isAnalysisMode
                          ? DeckInsightView(
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
              CardHistoryDrawer(
                drawerCubit: drawerCubit,
                readerCubit: readerCubit,
              ),
              CreateRoomDrawer(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}
