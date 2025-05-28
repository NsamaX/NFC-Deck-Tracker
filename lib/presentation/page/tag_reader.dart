import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '../cubit/drawer_cubit.dart';
import '../cubit/reader_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/shared/history_drawer.dart';
import '../widget/specific/collection_drawer.dart';
import '../widget/specific/nfc_button_icon.dart';
import '../widget/specific/nfc_read_tag_listener.dart';

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
        BlocProvider.value(value: locator<DrawerCubit>()),
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
    final drawerCubit = context.read<DrawerCubit>();

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem(
            label: Icons.history_rounded,
            action: () {
              drawerCubit.toggleHistoryDrawer();
            },
          ),
          AppBarMenuItem(
            label: locale.translate('page_card_reader.app_bar'),
          ),
          AppBarMenuItem(
            label: Icons.search_rounded,
            action: () {
              drawerCubit.toggleFeatureDrawer();
            },
          ),
        ],
      ),
      body: NfcReadTagListener(
        onTagDetected: onTagDetected,
        child: GestureDetector(
          onTap: () {
            drawerCubit.closeAllDrawer();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: const [
              NfcButtonIconWidget(),
              HistoryDrawerWidget(),
              CollectionDrawerWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
