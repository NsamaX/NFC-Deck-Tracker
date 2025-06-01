import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../../cubit/deck_cubit.dart';
import '../../../cubit/nfc_cubit.dart';
import '../../../locale/localization.dart';
import '../../../route/route_constant.dart';

import '../../shared/app_bar.dart';
import '../../shared/cupertino_dialog.dart';
import '../../shared/snackbar.dart';

class AppBarDeckBuilderPage extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final TextEditingController nameController;

  const AppBarDeckBuilderPage({
    super.key,
    required this.userId,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    final List<AppBarMenuItem> menuItems;

    if (context.watch<DeckCubit>().state.currentDeck.cards!.isEmpty) {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: context.read<DeckCubit>().state.currentDeck.name!,
        ),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.collection,
            'arguments': {
              'onAdd': true,
            },
          },
        ),
      ];
    } 
    else if (context.watch<DeckCubit>().state.isNewDeck) {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem.empty(),
        AppBarMenuItem(
          label: context.read<DeckCubit>().state.currentDeck.name!,
        ),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.browse_card,
            'arguments': {
              'onAdd': true,
            },
          },
        ),
        AppBarMenuItem(
          label: locale.translate('page_deck_create.toggle_save'),
          action: () => context.read<DeckCubit>().saveDeck(userId: userId),
        ),
      ];
    } 
    else if (context.watch<DeckCubit>().state.isEditMode) {
      menuItems = [
        AppBarMenuItem(
          label: Icons.nfc_rounded,
          action: () {
            if (context.read<NfcCubit>().state.isSessionActive) {
              context.read<NfcCubit>().stopSession();
              context.read<DeckCubit>().toggleSelectCard(card: CardEntity());
            } else {
              context.read<NfcCubit>().startSession(card: context.read<DeckCubit>().state.selectedCard);
            }
          },
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
                context.read<DeckCubit>().setDeckName(
                  name: trimmed.isNotEmpty
                      ? trimmed
                      : locale.translate('page_deck_create.app_bar'),
                );
              },
              onSubmitted: (_) => _rename(context),
            ),
          ),
        ),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.browse_card,
            'arguments': {
              'collectionId': context.read<DeckCubit>().state.currentDeck.cards?.first.card.collectionId,
              'collectionName': context.read<DeckCubit>().state.currentDeck.cards?.first.card.collectionId,
              'onAdd': true,
            },
          },
        ),
        AppBarMenuItem(
          label: locale.translate('page_deck_create.toggle_save'),
          action: () {
            context.read<DeckCubit>().saveDeck(userId: userId);
            context.read<DeckCubit>().closeEditMode();
          },
        ),
      ];
    } 
    else {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.ios_share_rounded,
          action: () => _toggleShare(context),
        ),
        AppBarMenuItem(
          label: context.read<DeckCubit>().state.currentDeck.name!,
        ),
        const AppBarMenuItem(
          label: Icons.play_arrow_rounded,
          action: RouteConstant.deck_tracker,
        ),
        AppBarMenuItem(
          label: locale.translate('page_deck_create.toggle_edit'),
          action: () => context.read<DeckCubit>().toggleEditMode(),
        ),
      ];
    }

    return AppBarWidget(menu: menuItems);
  }

  void _showDeleteDialog(BuildContext context) {
    final locale = AppLocalization.of(context);

    buildCupertinoActionDialog(
      title: locale.translate('page_deck_create.dialog_delete_title'),
      content: locale.translate('page_deck_create.dialog_delete_content'),
      cancelButtonText: locale.translate('common.button_cancel'),
      confirmButtonText: locale.translate('common.button_confirm'),
      onPressed: () {
        context.read<DeckCubit>().toggleDeleteDeck();
        AppSnackBar(
          context, 
          text: locale.translate('page_deck_create.snack_bar_delete'),
        );
      },
      closeDialog: () => Navigator.of(context).pop(),
      showDialog: (dialog) => showCupertinoDialog(context: context, builder: (_) => dialog),
    );
  }

  void _rename(BuildContext context) {
    final locale = AppLocalization.of(context);

    final value = nameController.text;
    final newName = value.trim().isNotEmpty
        ? value.trim()
        : locale.translate('page_deck_create.app_bar');

    context.read<DeckCubit>().setDeckName(name: newName);
    nameController.text = newName;
  }

  void _toggleShare(BuildContext context) {
    final locale = AppLocalization.of(context);

    context.read<DeckCubit>().toggleShare(locale: locale);
    AppSnackBar(
      context, 
      text: locale.translate('page_deck_create.snack_bar_share'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
