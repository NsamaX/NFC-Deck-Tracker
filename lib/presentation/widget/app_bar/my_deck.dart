import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/deck_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

import '@default.dart';

class MyDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyDeckAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(menu: _buildMenu(context));
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();
    final hasDecks = context.watch<DeckCubit>().state.decks.isNotEmpty;

    return [
      AppBarMenuItem(
        label: Icons.open_in_new_rounded,
        action: () {
          deckCubit.createEmptyDeck(locale: locale);
          Navigator.of(context).pushNamed(RouteConstant.deck_builder);
        },
      ),
      AppBarMenuItem(label: locale.translate('page_deck_list.app_bar')),
      hasDecks
          ? AppBarMenuItem(
              label: Icons.edit_rounded,
              action: deckCubit.toggleEditMode,
            )
          : AppBarMenuItem.empty(),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
