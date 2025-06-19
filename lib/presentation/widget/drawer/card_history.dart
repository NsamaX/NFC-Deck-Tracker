import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../cubit/drawer.dart';
import '../../cubit/reader.dart';
import '../../locale/localization.dart';

import '../card/list_tile.dart';
import '../constant/ui.dart';

class CardHistoryDrawer extends StatelessWidget {
  final DrawerCubit drawerCubit;
  final ReaderCubit readerCubit;
  final bool onNfc;

  const CardHistoryDrawer({
    super.key,
    required this.drawerCubit,
    required this.readerCubit,
    this.onNfc = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final reversedCards = List<CardEntity>.from(readerCubit.state.scannedCards.reversed);

    return AnimatedPositioned(
      duration: UIConstant.drawerTransitionDuration,
      curve: Curves.easeInOut,
      left: drawerCubit.state.visibleHistoryDrawer ? 0 : -UIConstant.historyDrawerWidth,
      top: 0,
      bottom: 0,
      child: Container(
        width: UIConstant.historyDrawerWidth,
        height: mediaQuery.size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(0, 3),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ListView.builder(
          itemCount: reversedCards.length,
          itemBuilder: (_, index) => CardListTile(
            locale: locale,
            theme: theme,
            mediaQuery: mediaQuery,
            navigator: Navigator.of(context),
            card: reversedCards[index],
            lightTheme: true,
            onNFC: onNfc,
          ),
        ),
      ),
    );
  }
}
