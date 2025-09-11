import 'package:flutter/material.dart';

import '../../bloc/deck/bloc.dart';
import '../../locale/localization.dart';
import '../../route/constant.dart';

import '@default.dart';

class NewDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalization locale;
  final ThemeData theme;
  final DeckBloc deckBloc;
  final TextEditingController nameController;
  final String userId;

  const NewDeckAppBar({
    super.key,
    required this.locale,
    required this.theme,
    required this.deckBloc,
    required this.nameController,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final deckState = deckBloc.state;
    final deckName = deckState.currentDeck.name ?? '';
    final hasCards = deckState.currentDeck.cards?.isNotEmpty == true;
    final String collectionId = hasCards
        ? deckState.currentDeck.cards?.first.card.collectionId ?? ''
        : '';

    List<AppBarMenuItem> menuItems;

    if (!hasCards) {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(label: deckName),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.collection,
            'arguments': {'onAdd': true},
          },
        ),
      ];
    } else {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem.empty(),
        AppBarMenuItem(label: deckName),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.browse_card,
            'arguments': {
              'collectionId': collectionId,
              'collectionName': collectionId,
              'onAdd': true,
            },
          },
        ),
        AppBarMenuItem(
          label: locale.translate('page_deck_builder.toggle_save'),
          action: () => deckBloc.add(CreateDeckEvent(userId: userId)),
        ),
      ];
    }

    return DefaultAppBar(
      menu: menuItems,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
