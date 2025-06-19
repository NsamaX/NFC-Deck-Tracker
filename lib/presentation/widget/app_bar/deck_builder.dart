import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../bloc/deck_bloc.dart';
import '../../cubit/application.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

import '../notification/cupertino_dialog.dart';
import '../notification/snackbar.dart';
import '../specific/tutorail_nfc_icon.dart';

import '@default.dart';

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
    final applicationCubit = context.read<ApplicationCubit>();
    final deckCubit = context.read<DeckBloc>();
    final nfcCubit = context.read<NfcCubit>();
    final deckState = context.watch<DeckBloc>().state;

    final deckName = deckState.currentDeck.name ?? '';
    final hasCards = deckState.currentDeck.cards?.isNotEmpty == true;

    final String collectionId = hasCards
        ? deckState.currentDeck.cards?.first.card.collectionId ?? ''
        : '';

    if (!hasCards && deckState.isNewDeck || collectionId.isEmpty) {
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

    if (hasCards && deckState.isNewDeck) {
      return [
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
          action: () => deckCubit.add(CreateDeckEvent(userId: userId))
        ),
      ];
    }

    if (deckState.isEditMode) {
      final Widget nameFieldWidget = TextField(
        controller: nameController,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: locale.translate('page_deck_builder.app_bar'),
        ),
        onChanged: (value) {
          final trimmed = value.trim();
          deckCubit.add(SetDeckNameEvent(name: trimmed.isNotEmpty ? trimmed : locale.translate('page_deck_builder.app_bar')));
        },
        onSubmitted: (_) {
          final trimmed = nameController.text.trim();
          final newName = trimmed.isNotEmpty
              ? trimmed
              : locale.translate('page_deck_builder.app_bar');

          deckCubit.add(SetDeckNameEvent(name: newName));
          nameController.text = newName;
        },
      );

      return [
        AppBarMenuItem(
          label: Icons.nfc_rounded,
          action: () {
            if (nfcCubit.state.isSessionActive) {
              nfcCubit.stopSession();
              deckCubit.add(SelectCardEvent(card: CardEntity()));
            } else {
              nfcCubit.startSession(card: deckState.selectedCard);
            }
          },
        ),
        AppBarMenuItem(
          label: Icons.delete_outline_rounded,
          action: () {
            buildCupertinoActionDialog(
              theme: Theme.of(context),
              title: locale.translate('page_deck_builder.dialog_delete_title'),
              content: locale.translate('page_deck_builder.dialog_delete_content'),
              cancelButtonText: locale.translate('common.button_cancel'),
              confirmButtonText: locale.translate('common.button_confirm'),
              onPressed: () {
                deckCubit.add(DeleteDeckEvent(userId: userId, deckId: deckState.currentDeck.deckId!, locale: locale));
                Navigator.of(context).pop();
                AppSnackBar(context, text: locale.translate('page_deck_builder.snack_bar_delete'));
              },
              closeDialog: () => Navigator.of(context).pop(),
              showDialog: (dialog) => showCupertinoDialog(context: context, builder: (_) => dialog),
            );
          },
        ),
        AppBarMenuItem(label: nameFieldWidget),
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
          action: () {
            deckCubit.add(UpdateDeckEvent(userId: userId));
            deckCubit.add(CloseEditModeEvent());
          },
        ),
      ];
    }

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: Icons.ios_share_rounded,
        action: () {
          deckCubit.add(ToggleShareEvent(locale: locale));
          AppSnackBar(context, text: locale.translate('page_deck_builder.snack_bar_share'));
        },
      ),
      AppBarMenuItem(label: deckName),
      const AppBarMenuItem(
        label: Icons.play_arrow_rounded,
        action: RouteConstant.deck_tracker,
      ),
      AppBarMenuItem(
        label: locale.translate('page_deck_builder.toggle_edit'),
        action: () {
          deckCubit.add(ToggleEditModeEvent());
          if (!applicationCubit.state.tutorialNfcIcon) {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Tutorial",
              transitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (_, __, ___) => const TutorailNFCIcon(),
            );
            applicationCubit.updateSetting(key: AppConfig.keyTutorialNFCIcon, value: true);
          }
        }
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
