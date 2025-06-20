import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../bloc/deck/bloc.dart';
import '../bloc/drawer/bloc.dart';
import '../bloc/pin_card/bloc.dart';
import '../bloc/room/bloc.dart';
import '../bloc/tracker/bloc.dart';
import '../bloc/usage_card/bloc.dart';
import '../cubit/nfc_cubit.dart';
import '../cubit/reader.dart';
import '../cubit/record.dart';
import '../locale/localization.dart';
import '../widget/app_bar/deck_tracker.dart';
import '../widget/deck/insight_view.dart';
import '../widget/deck/switch_mode.dart';
import '../widget/deck/tracker_view.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/create_room.dart';
import '../widget/listener/deck_tracker.dart';
import '../widget/notification/cupertino_dialog.dart';

class DeckTrackerPage extends StatefulWidget {
  const DeckTrackerPage({super.key});

  @override
  State<DeckTrackerPage> createState() => _DeckTrackerPageState();
}

class _DeckTrackerPageState extends State<DeckTrackerPage> {
  late final String userId;
  late final String collectionId;
  late final DeckEntity deck;

  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownDialog) {
        _hasShownDialog = true;

        final locale = AppLocalization.of(context);

        buildCupertinoAlertDialog(
          theme: Theme.of(context),
          title: locale.translate('page_deck_tracker.dialog_tracker_tutorial_title'),
          content: locale.translate('page_deck_tracker.dialog_tracker_tutorial_content'),
          confirmButtonText: locale.translate('common.button_ok'),
          onPressed: () => context.read<NfcCubit>().startSession(),
          closeDialog: () => Navigator.of(context, rootNavigator: true).pop(),
          showDialog: (dialog) => showCupertinoDialog(
            context: context,
            builder: (_) => dialog,
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
    collectionId = GameConfig.dummy;
    deck = context.read<DeckBloc>().state.currentDeck;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<DrawerBloc>()),
        BlocProvider.value(value: locator<PinCardBloc>()),
        BlocProvider.value(value: locator<UsageCardBloc>()),
        BlocProvider.value(value: locator<ReaderCubit>(param1: collectionId)),
        BlocProvider.value(value: locator<RecordCubit>(param1: deck.deckId)),
        BlocProvider.value(value: locator<RoomBloc>(param1: deck)),
        BlocProvider.value(value: locator<TrackerBloc>(param1: deck)),
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
    final trackerCubit = context.watch<TrackerBloc>();
    final readerCubit = context.watch<ReaderCubit>();
    final drawerCubit = context.watch<DrawerBloc>();
    final recordCubit = context.watch<RecordCubit>();
    final roomCubit = context.watch<RoomBloc>();
    final usageCardCubit = context.watch<UsageCardBloc>();
    final locale = AppLocalization.of(context);

    return DeckTrackerListener(
      child: Scaffold(
        appBar: DeckTrackerAppBar(
          userId: userId,
          nfcCubit: context.watch<NfcCubit>(),
        ),
        body: GestureDetector(
          onTap: () => drawerCubit.add(CloseAllDrawerEvent()),
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
                      onSelected: (_) => trackerCubit.add(ToggleAnalysisModeEvent()),
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
                onNfc: false,
              ),
              CreateRoomDrawer(
                userId: userId,
                roomCubit: roomCubit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
