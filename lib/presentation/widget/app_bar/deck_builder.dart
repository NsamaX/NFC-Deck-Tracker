import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '@default.dart';

import '../notification/cupertino_dialog.dart';
import '../notification/snackbar.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

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
    return DefaultAppBar(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();
    final deckState = context.watch<DeckCubit>().state;

    final deckName = deckState.currentDeck.name ?? '';
    final hasCards = deckState.currentDeck.cards?.isNotEmpty == true;
    final collectionId = deckState.currentDeck.cards?.first.card.collectionId;

    if (!hasCards) {
      return [
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
    }

    if (deckState.isNewDeck) {
      return [
        AppBarMenuItem.back(),
        AppBarMenuItem.empty(),
        AppBarMenuItem(label: deckName),
        AppBarMenuItem(
          label: Icons.add_rounded,
          action: {
            'route': RouteConstant.browse_card,
            'arguments': {'onAdd': true},
          },
        ),
        AppBarMenuItem(
          label: locale.translate('page_deck_create.toggle_save'),
          action: () => deckCubit.saveDeck(userId: userId),
        ),
      ];
    }

    if (deckState.isEditMode) {
      final nameField = Expanded(
        child: TextField(
          controller: nameController,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: locale.translate('page_deck_create.app_bar'),
          ),
          onChanged: (value) {
            final trimmed = value.trim();
            deckCubit.setDeckName(
              name: trimmed.isNotEmpty ? trimmed : locale.translate('page_deck_create.app_bar'),
            );
          },
          onSubmitted: (_) {
            final trimmed = nameController.text.trim();
            final newName = trimmed.isNotEmpty
                ? trimmed
                : locale.translate('page_deck_create.app_bar');

            deckCubit.setDeckName(name: newName);
            nameController.text = newName;
          },
        ),
      );

      return [
        AppBarMenuItem(
          label: Icons.nfc_rounded,
          action: () {
            if (nfcCubit.state.isSessionActive) {
              nfcCubit.stopSession();
              deckCubit.toggleSelectCard(card: CardEntity());
            } else {
              nfcCubit.startSession(card: deckState.selectedCard);
            }
          },
        ),
        AppBarMenuItem(
          label: Icons.delete_outline_rounded,
          action: () {
            buildCupertinoActionDialog(
              title: locale.translate('page_deck_create.dialog_delete_title'),
              content: locale.translate('page_deck_create.dialog_delete_content'),
              cancelButtonText: locale.translate('common.button_cancel'),
              confirmButtonText: locale.translate('common.button_confirm'),
              onPressed: () {
                deckCubit.toggleDeleteDeck();
                AppSnackBar(context, text: locale.translate('page_deck_create.snack_bar_delete'));
              },
              closeDialog: () => Navigator.of(context).pop(),
              showDialog: (dialog) => showCupertinoDialog(context: context, builder: (_) => dialog),
            );
          },
        ),
        AppBarMenuItem(label: nameField),
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
          label: locale.translate('page_deck_create.toggle_save'),
          action: () {
            deckCubit.saveDeck(userId: userId);
            deckCubit.closeEditMode();
          },
        ),
      ];
    }

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: Icons.ios_share_rounded,
        action: () {
          deckCubit.toggleShare(locale: locale);
          AppSnackBar(context, text: locale.translate('page_deck_create.snack_bar_share'));
        },
      ),
      AppBarMenuItem(label: deckName),
      const AppBarMenuItem(
        label: Icons.play_arrow_rounded,
        action: RouteConstant.deck_tracker,
      ),
      AppBarMenuItem(
        label: locale.translate('page_deck_create.toggle_edit'),
        action: () => deckCubit.toggleEditMode(),
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
