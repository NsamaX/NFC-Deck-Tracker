import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../bloc/drawer/bloc.dart';
import '../cubit/application.dart';
import '../cubit/nfc_cubit.dart';
import '../cubit/reader.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/drawer/card_history.dart';
import '../widget/drawer/collection.dart';
import '../widget/listener/tag_reader.dart';
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
        BlocProvider(create: (_) => locator<ReaderCubit>(param1: _collectionId)),
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
      body: TagReaderListener(
        onTagDetected: onTagDetected,
        child: GestureDetector(
          onTap: () {
            context.read<DrawerBloc>().add(CloseAllDrawerEvent());
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              BlocBuilder<NfcCubit, NfcState>(
                builder: (context, state) {
                  return NfcIcon(
                    isSessionActive: state.isSessionActive,
                    onTap: () => state.isSessionActive
                        ? context.read<NfcCubit>().stopSession()
                        : context.read<NfcCubit>().startSession(),
                  );
                },
              ),
              BlocBuilder<DrawerBloc, DrawerState>(
                buildWhen: (prev, curr) => prev.visibleHistoryDrawer != curr.visibleHistoryDrawer,
                builder: (context, drawerState) {
                  return BlocBuilder<ReaderCubit, ReaderState>(
                    builder: (context, readerState) {
                      return CardHistoryDrawer(
                        drawerCubit: context.watch<DrawerBloc>(),
                        readerCubit: context.watch<ReaderCubit>(),
                      );
                    },
                  );
                },
              ),
              BlocBuilder<ApplicationCubit, ApplicationState>(
                builder: (context, appState) {
                  return BlocBuilder<DrawerBloc, DrawerState>(
                    buildWhen: (prev, curr) => prev.visibleFeatureDrawer != curr.visibleFeatureDrawer,
                    builder: (context, drawerState) {
                      return CollectionDrawer(
                        key: ValueKey(appState.recentId),
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
