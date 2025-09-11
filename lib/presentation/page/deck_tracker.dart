import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../bloc/deck/bloc.dart';
import '../bloc/drawer/bloc.dart';
import '../bloc/nfc/bloc.dart';
import '../bloc/pin_card/bloc.dart';
import '../bloc/reader/bloc.dart';
import '../bloc/record/bloc.dart';
import '../bloc/tracker/bloc.dart';
import '../bloc/usage_card/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/deck_tracker.dart';
import '../widget/deck/insight_view.dart';
import '../widget/deck/switch_mode.dart';
import '../widget/deck/tracker_view.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/share_record.dart';
import '../widget/listener/tracker.dart';
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
          onPressed: () => context.read<NfcBloc>().add(StartNfcSessionEvent()),
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
        BlocProvider(create: (_) => locator<DrawerBloc>()),
        BlocProvider(create: (_) => locator<PinCardBloc>()),
        BlocProvider(create: (_) => locator<UsageCardBloc>()),
        BlocProvider(create: (_) => locator<ReaderBloc>(param1: collectionId)),
        BlocProvider(create: (_) => locator<RecordBloc>(param1: deck.deckId)),
        BlocProvider(create: (_) => locator<TrackerBloc>(param1: deck)),
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
    final trackerBloc = context.watch<TrackerBloc>();
    final readerBloc = context.watch<ReaderBloc>();
    final drawerBloc = context.watch<DrawerBloc>();
    final recordBloc = context.watch<RecordBloc>();
    final usageCardBloc = context.watch<UsageCardBloc>();
    final locale = AppLocalization.of(context);

    return TrackerListener(
      child: Scaffold(
        appBar: DeckTrackerAppBar(
          userId: userId,
          nfcBloc: context.watch<NfcBloc>(),
        ),
        body: GestureDetector(
          onTap: () => drawerBloc.add(CloseDrawerEvent()),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: drawerBloc.state.visibleHistoryDrawer || drawerBloc.state.visibleFeatureDrawer,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    DeckSwitchMode(
                      isAnalyzeModeEnabled: trackerBloc.state.isAnalysisMode,
                      onSelected: (_) => trackerBloc.add(ToggleAnalysisModeEvent()),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: trackerBloc.state.isAnalysisMode
                          ? DeckInsightView(
                              locale: locale,
                              readerBloc: readerBloc,
                              trackerBloc: trackerBloc,
                              recordBloc: recordBloc,
                              usageCardBloc: usageCardBloc,
                              userId: userId,
                            )
                          : DeckTrackerView(),
                    ),
                  ],
                ),
              ),
              CardHistoryDrawer(
                drawerBloc: drawerBloc,
                readerBloc: readerBloc,
                onNfc: false,
              ),
              ShareRecordDrawer(
                userId: userId,
                cards: [],
                recordBloc: recordBloc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
