import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../bloc/drawer/bloc.dart';
import '../bloc/deck_builder/bloc.dart';
import '../bloc/nfc/bloc.dart';
import '../bloc/tracker/bloc.dart';
import '../widget/app_bar/deck_tracker.dart';
import '../widget/deck/insight_view.dart';
import '../widget/deck/switch_mode.dart';
import '../widget/deck/tracker_view.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/share_record.dart';
import '../widget/listener/tracker.dart';
import '../widget/listener/error.dart';

class DeckTrackerPage extends StatefulWidget {
  const DeckTrackerPage({super.key});

  @override
  State<DeckTrackerPage> createState() => _DeckTrackerPageState();
}

class _DeckTrackerPageState extends State<DeckTrackerPage> {
  late final DeckEntity deck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NfcBloc>().add(StartNfcSessionEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deck = context.read<DeckBuilderBloc>().state.currentDeck;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => PresentationScope.read(context).createDrawerBloc()),
        BlocProvider(
            create: (_) => PresentationScope.read(context).createPinCardBloc()),
        BlocProvider(
            create: (_) => PresentationScope.read(context).createReaderBloc()),
        BlocProvider(
            create: (_) =>
                PresentationScope.read(context).createTrackerBloc(deck)),
      ],
      child: ErrorListener<TrackerBloc, TrackerState>(
        errorOf: (state) => state.errorMessage,
        child: const _DeckTrackerPageContent(),
      ),
    );
  }
}

class _DeckTrackerPageContent extends StatelessWidget {
  const _DeckTrackerPageContent();

  @override
  Widget build(BuildContext context) {
    final trackerBloc = context.watch<TrackerBloc>();
    final drawerBloc = context.watch<DrawerBloc>();

    return TrackerListener(
      child: Scaffold(
        appBar: const DeckTrackerAppBar(),
        body: GestureDetector(
          onTap: () => drawerBloc.add(CloseDrawerEvent()),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: drawerBloc.state.visibleHistoryDrawer ||
                    drawerBloc.state.visibleFeatureDrawer,
                child: Column(
                  children: [
                    const SizedBox(height: 16.0),
                    DeckSwitchMode(
                      isAnalyzeModeEnabled: trackerBloc.state.isAnalysisMode,
                      onSelected: (_) =>
                          trackerBloc.add(ToggleAnalysisModeEvent()),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      child: trackerBloc.state.isAnalysisMode
                          ? DeckInsightView()
                          : DeckTrackerView(),
                    ),
                  ],
                ),
              ),
              CardHistoryDrawer(
                onNfc: false,
              ),
              ShareRecordDrawer(
                cards: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
