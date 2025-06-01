import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '../cubit/application_cubit.dart';
import '../cubit/drawer_cubit.dart';
import '../cubit/nfc_cubit.dart';
import '../cubit/reader_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/shared/history_drawer.dart';
import '../widget/specific/collection_drawer.dart';
import '../widget/specific/nfc_button_icon.dart';
import '../widget/specific/reader_listener.dart';

class TagReaderPage extends StatefulWidget {
  const TagReaderPage({super.key});

  @override
  State<TagReaderPage> createState() => _TagReaderPageState();
}

class _TagReaderPageState extends State<TagReaderPage> {
  String _collectionId = GameConstant.dummy;

  void _onTagDetected(String newCollectionId) {
    setState(() {
      _collectionId = newCollectionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => locator<DrawerCubit>(),
        ),
        BlocProvider(
          create: (_) => locator<ReaderCubit>(param1: _collectionId),
        ),
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
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem(
            label: Icons.history_rounded,
            action: () {
              context.read<DrawerCubit>().toggleHistoryDrawer();
            },
          ),
          AppBarMenuItem(
            label: locale.translate('page_card_reader.app_bar'),
          ),
          AppBarMenuItem(
            label: Icons.search_rounded,
            action: () {
              context.read<DrawerCubit>().toggleFeatureDrawer();
            },
          ),
        ],
      ),
      body: ReaderListener(
        onTagDetected: onTagDetected,
        child: GestureDetector(
          onTap: () {
            context.read<DrawerCubit>().closeAllDrawer();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              BlocBuilder<NfcCubit, NfcState>(
                builder: (context, state) {
                  return NfcButtonIconWidget(
                    isSessionActive: state.isSessionActive,
                    onTap: () => state.isSessionActive
                        ? context.read<NfcCubit>().stopSession()
                        : context.read<NfcCubit>().startSession(),
                  );
                },
              ),
              BlocBuilder<DrawerCubit, DrawerState>(
                buildWhen: (prev, curr) => prev.visibleHistoryDrawer != curr.visibleHistoryDrawer,
                builder: (context, drawerState) {
                  return BlocBuilder<ReaderCubit, ReaderState>(
                    builder: (context, readerState) {
                      return HistoryDrawer(
                        isOpen: drawerState.visibleHistoryDrawer,
                        cards: readerState.scannedCards,
                      );
                    },
                  );
                },
              ),
              BlocBuilder<DrawerCubit, DrawerState>(
                buildWhen: (prev, curr) => prev.visibleFeatureDrawer != curr.visibleFeatureDrawer,
                builder: (context, drawerState) {
                  return BlocBuilder<ApplicationCubit, ApplicationState>(
                    builder: (context, appState) {
                      return CollectionDrawerWidget(
                        isOpen: drawerState.visibleFeatureDrawer,
                        recentId: appState.recentId,
                        recentGame: appState.recentGame,
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
