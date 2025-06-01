import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/deck_cubit.dart';
import '../../../locale/localization.dart';
import '../../../route/route_constant.dart';

import '../../shared/app_bar.dart';

class AppBarMyDeckPage extends StatelessWidget implements PreferredSizeWidget {
  const AppBarMyDeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(menu: _buildMenu(context));
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);

    return [
      AppBarMenuItem(
        label: Icons.open_in_new_rounded,
        action: () => _createNewDeck(context),
      ),
      AppBarMenuItem(label: locale.translate('page_deck_list.app_bar')),
      context.watch<DeckCubit>().state.decks.isNotEmpty
          ? AppBarMenuItem(
              label: Icons.edit_rounded,
              action: context.read<DeckCubit>().toggleEditMode,
            )
          : AppBarMenuItem.empty(),
    ];
  }

  void _createNewDeck(BuildContext context) {
    final locale = AppLocalization.of(context);

    context.read<DeckCubit>().createNewDeck(locale: locale);
    Navigator.of(context).pushNamed(RouteConstant.deck_builder);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
