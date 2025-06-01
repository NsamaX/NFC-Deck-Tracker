import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import 'ui_constant.dart';

import '../material/card_list_tile.dart';

import '../../locale/localization.dart';

class HistoryDrawer extends StatelessWidget {
  final bool isOpen;
  final List<CardEntity> cards;

  const HistoryDrawer({
    super.key,
    required this.isOpen,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final reversedCards = List<CardEntity>.from(cards.reversed);

    return AnimatedPositioned(
      duration: UIConstant.drawerTransitionDuration,
      curve: Curves.easeInOut,
      left: isOpen ? 0 : -UIConstant.historyDrawerWidth,
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
          itemBuilder: (_, index) => CardListTileWidget(
            locale: locale,
            theme: theme,
            mediaQuery: mediaQuery,
            navigator: Navigator.of(context),
            card: reversedCards[index],
            lightTheme: true,
          ),
        ),
      ),
    );
  }
}
