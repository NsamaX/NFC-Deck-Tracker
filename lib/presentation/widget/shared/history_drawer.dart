import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import 'ui_constant.dart';

import '../material/card_list_tile.dart';

import '../../cubit/drawer_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../locale/localization.dart';

class HistoryDrawerWidget extends StatelessWidget {
  const HistoryDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final locale = AppLocalization.of(context);
    final navigator = Navigator.of(context);

    return BlocSelector<DrawerCubit, DrawerState, bool>(
      selector: (state) => state.visibleHistoryDrawer,
      builder: (context, isOpen) {
        return BlocSelector<ReaderCubit, ReaderState, List<CardEntity>>(
          selector: (state) => state.scannedCards,
          builder: (context, cards) => AnimatedPositioned(
            duration: UIConstant.drawerTransitionDuration,
            curve: Curves.easeInOut,
            left: isOpen ? 0 : -UIConstant.historyDrawerWidth,
            top: 0,
            bottom: 0,
            child: _buildDrawerContent(
              context: context,
              cards: cards,
              theme: theme,
              mediaQuery: mediaQuery,
              locale: locale,
              navigator: navigator,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerContent({
    required BuildContext context,
    required List<CardEntity> cards,
    required ThemeData theme,
    required MediaQueryData mediaQuery,
    required AppLocalization locale,
    required NavigatorState navigator,
  }) {
    final reversedCards = List<CardEntity>.from(cards.reversed);

    return Container(
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
          navigator: navigator,
          card: reversedCards[index],
          lightTheme: true,
        ),
      ),
    );
  }
}
