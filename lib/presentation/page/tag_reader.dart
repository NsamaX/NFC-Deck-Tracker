import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../bloc/application/bloc.dart';
import '../bloc/drawer/bloc.dart';
import '../bloc/nfc/bloc.dart';
import '../bloc/reader/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/collection.dart';
import '../widget/listener/reader.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/specific/nfc_icon.dart';

class TagReaderPage extends StatefulWidget {
  const TagReaderPage({super.key});

  @override
  State<TagReaderPage> createState() => _TagReaderPageState();
}

class _TagReaderPageState extends State<TagReaderPage> {
  String _collectionId = GameConfig.dummy;

  void _onTagDetected(String newCollectionId) {
    setState(() {
      _collectionId = newCollectionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => locator<DrawerBloc>()),
        BlocProvider(create: (_) => locator<ReaderBloc>(param1: _collectionId)),
      ],
      child: _TagReaderPageContent(onTagDetected: _onTagDetected),
    );
  }
}

class _TagReaderPageContent extends StatelessWidget {
  final void Function(String) onTagDetected;

  const _TagReaderPageContent({
    required this.onTagDetected,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem(
            label: Icons.history_rounded,
            action: () {
              context.read<DrawerBloc>().add(ToggleHistoryDrawerEvent());
            },
          ),
          AppBarMenuItem(
            label: locale.translate('page_card_reader.app_bar'),
          ),
          AppBarMenuItem(
            label: Icons.search_rounded,
            action: () {
              context.read<DrawerBloc>().add(ToggleFeatureDrawerEvent());
            },
          ),
        ],
      ),
      body: ReaderListener(
        onTagDetected: onTagDetected,
        child: GestureDetector(
          onTap: () {
            context.read<DrawerBloc>().add(CloseDrawerEvent());
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              BlocBuilder<NfcBloc, NfcState>(
                builder: (context, state) {
                  return NfcIcon(
                    isSessionActive: state.isSessionActive,
                    onTap: () => state.isSessionActive
                        ? context.read<NfcBloc>().add(StopNfcSessionEvent())
                        : context.read<NfcBloc>().add(StartNfcSessionEvent()),
                  );
                },
              ),
              BlocBuilder<DrawerBloc, DrawerState>(
                buildWhen: (prev, curr) => prev.visibleHistoryDrawer != curr.visibleHistoryDrawer,
                builder: (context, drawerState) {
                  return BlocBuilder<ReaderBloc, ReaderState>(
                    builder: (context, readerState) {
                      return CardHistoryDrawer(
                        drawerBloc: context.watch<DrawerBloc>(),
                        readerBloc: context.watch<ReaderBloc>(),
                      );
                    },
                  );
                },
              ),
              BlocBuilder<ApplicationBloc, ApplicationState>(
                builder: (context, appState) {
                  return BlocBuilder<DrawerBloc, DrawerState>(
                    buildWhen: (prev, curr) => prev.visibleFeatureDrawer != curr.visibleFeatureDrawer,
                    builder: (context, drawerState) {
                      return CollectionDrawer(
                        key: ValueKey(appState.recentId),
                        isOpen: drawerState.visibleFeatureDrawer,
                        recentId: appState.recentId ?? '',
                        recentGame: appState.recentGame ?? '',
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
