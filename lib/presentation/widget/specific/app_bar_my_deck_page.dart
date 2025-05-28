import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/app_bar.dart';

import '../../cubit/deck_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route.dart';

class MyDeckAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyDeckAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(menu: _buildMenu(context));
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();
    final showEdit = deckCubit.state.decks.isNotEmpty;

    return [
      AppBarMenuItem(
        label: Icons.open_in_new_rounded,
        action: () => _createNewDeck(context),
      ),
      AppBarMenuItem(label: locale.translate('page_deck_list.app_bar')),
      showEdit
          ? AppBarMenuItem(
              label: Icons.edit_rounded,
              action: deckCubit.toggleEditMode,
            )
          : AppBarMenuItem.empty(),
    ];
  }

  void _createNewDeck(BuildContext context) {
    final deckCubit = context.read<DeckCubit>();
    final locale = AppLocalization.of(context);

    deckCubit.createNewDeck(locale: locale);
    if (deckCubit.state.isEditMode) {
      deckCubit.toggleEditMode();
    }

    Navigator.of(context).pushNamed(RouteConstant.deck_builder);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
