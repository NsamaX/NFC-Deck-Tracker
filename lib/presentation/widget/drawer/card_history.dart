import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../bloc/drawer/bloc.dart';
import '../../bloc/reader/bloc.dart';
import '../../locale/localization.dart';
import '../../constant.dart';

import '../card/list_tile.dart';

class CardHistoryDrawer extends StatelessWidget {
  final DrawerBloc drawerBloc;
  final ReaderBloc readerBloc;
  final bool onNfc;

  const CardHistoryDrawer({
    super.key,
    required this.drawerBloc,
    required this.readerBloc,
    this.onNfc = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final reversedCards = List<CardEntity>.from(readerBloc.state.readedCards.reversed);

    return AnimatedPositioned(
      duration: WidgetConstant.drawerTransitionDuration,
      curve: Curves.easeInOut,
      left: drawerBloc.state.visibleHistoryDrawer ? 0 : -WidgetConstant.historyDrawerWidth,
      top: 0,
      bottom: 0,
      child: Container(
        width: WidgetConstant.historyDrawerWidth,
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
