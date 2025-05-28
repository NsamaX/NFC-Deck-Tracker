import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/app_bar.dart';
import '../shared/cupertino_dialog.dart';
import '../shared/snackbar.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route.dart';

class DeckBuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final TextEditingController nameController;

  const DeckBuilderAppBar({
    super.key,
    required this.userId,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = _buildMenu(context);
    return AppBarWidget(menu: menuItems);
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();
    final deck = deckCubit.state.currentDeck;

    if (deck.cards != null) {
      return _defaultMenu(context);
    } else if (deckCubit.state.isNewDeck) {
      return _newDeckMenu(context, locale, deckCubit, nfcCubit);
    } else if (deckCubit.state.isEditMode) {
      return _editDeckMenu(context, locale, theme, deckCubit, nfcCubit);
    } else {
      return _viewDeckMenu(context, locale, deckCubit);
    }
  }

  List<AppBarMenuItem> _defaultMenu(BuildContext context) {
    final deck = context.read<DeckCubit>().state.currentDeck;

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(label: deck.name!),
      AppBarMenuItem(
        label: Icons.add_rounded,
        action: {
          'route': RouteConstant.collection,
          'arguments': {'isAdd': true},
        },
      ),
    ];
  }

  List<AppBarMenuItem> _newDeckMenu(
    BuildContext context,
    AppLocalization locale,
    DeckCubit deckCubit,
    NfcCubit nfcCubit,
  ) {
    final deck = deckCubit.state.currentDeck;

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem.empty(),
      AppBarMenuItem(label: deck.name!),
      AppBarMenuItem(
        label: Icons.add_rounded,
        action: {
          'route': RouteConstant.collection,
          'arguments': {'isAdd': true},
        },
      ),
      AppBarMenuItem(
        label: locale.translate('page_deck_create.toggle_save'),
        action: () {
          deckCubit.saveDeck(userId: userId);
          nfcCubit.stopSession();
        },
      ),
    ];
  }

  List<AppBarMenuItem> _editDeckMenu(
    BuildContext context,
    AppLocalization locale,
    ThemeData theme,
    DeckCubit deckCubit,
    NfcCubit nfcCubit,
  ) {
    final deck = deckCubit.state.currentDeck;

    return [
      AppBarMenuItem(
        label: Icons.nfc_rounded,
        action: () => nfcCubit.startSession(),
      ),
      AppBarMenuItem(
        label: Icons.delete_outline_rounded,
        action: () => _showDeleteDialog(context),
      ),
      AppBarMenuItem(
        label: Expanded(
          child: TextField(
            controller: nameController,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: locale.translate('page_deck_create.app_bar'),
            ),
            onChanged: (value) {
              final trimmed = value.trim();
              deckCubit.setDeckName(
                name: trimmed.isNotEmpty
                    ? trimmed
                    : locale.translate('page_deck_create.app_bar'),
              );
            },
            onSubmitted: (_) => _renameDeck(context),
          ),
        ),
      ),
      AppBarMenuItem(
        label: Icons.add_rounded,
        action: {
          'route': deck.cards != null
              ? RouteConstant.collection
              : RouteConstant.browse_card,
          'arguments': {
            'isAdd': true,
            'collectionId': deck.cards?.first.card.collectionId,
          },
        },
      ),
      AppBarMenuItem(
        label: locale.translate('page_deck_create.toggle_save'),
        action: () {
          deckCubit.saveDeck(userId: userId);
          deckCubit.toggleEditMode();
        },
      ),
    ];
  }

  List<AppBarMenuItem> _viewDeckMenu(
    BuildContext context,
    AppLocalization locale,
    DeckCubit deckCubit,
  ) {
    final deck = deckCubit.state.currentDeck;

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: Icons.ios_share_rounded,
        action: () => _toggleShare(context),
      ),
      AppBarMenuItem(label: deck.name!),
      const AppBarMenuItem(label: Icons.play_arrow_rounded, action: RouteConstant.deck_tracker),
      AppBarMenuItem(
        label: locale.translate('page_deck_create.toggle_edit'),
        action: () => deckCubit.toggleEditMode(),
      ),
    ];
  }

  void _showDeleteDialog(BuildContext context) {
    final locale = AppLocalization.of(context);
    final navigator = Navigator.of(context);
    final deckCubit = context.read<DeckCubit>();

    buildCupertinoActionDialog(
      title: locale.translate('page_deck_create.dialog_delete_title'),
      content: locale.translate('page_deck_create.dialog_delete_content'),
      cancelButtonText: locale.translate('common.button_cancel'),
      confirmButtonText: locale.translate('common.button_confirm'),
      onPressed: () {
        deckCubit.toggleDeleteDeck();
        showAppSnackBar(context, text: locale.translate('page_deck_create.snack_bar_delete'));
      },
      closeDialog: () => navigator.pop(),
      showDialog: (dialog) => showCupertinoDialog(context: context, builder: (_) => dialog),
    );
  }

  void _renameDeck(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();
    final value = nameController.text;

    final newName = value.trim().isNotEmpty
        ? value.trim()
        : locale.translate('page_deck_create.app_bar');

    deckCubit.setDeckName(name: newName);
    nameController.text = newName;
  }

  void _toggleShare(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();

    deckCubit.toggleShareDeck(locale: locale);
    showAppSnackBar(context, text: locale.translate('page_deck_create.snack_bar_share'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
