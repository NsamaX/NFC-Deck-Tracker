import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../bloc/application/bloc.dart';
import '../../bloc/deck/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../locale/localization.dart';
import '../../route/constant.dart';

import '../notification/cupertino_dialog.dart';
import '../notification/snackbar.dart';
import '../specific/tutorail_nfc_icon.dart';

import '@default.dart';

class DeckViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final TextEditingController nameController;
  final AppLocalization locale;
  final ThemeData theme;
  final ApplicationBloc applicationBloc;
  final DeckBloc deckBloc;
  final NfcBloc nfcBloc;

  const DeckViewAppBar({
    super.key,
    required this.userId,
    required this.nameController,
    required this.locale,
    required this.theme,
    required this.applicationBloc,
    required this.deckBloc,
    required this.nfcBloc,
  });

  @override
  Widget build(BuildContext context) {
    final deckState = deckBloc.state;
    final deckName = deckState.currentDeck.name ?? '';
    final hasCards = deckState.currentDeck.cards?.isNotEmpty == true;
    final collectionId = hasCards
        ? deckState.currentDeck.cards?.first.card.collectionId ?? ''
        : '';

    List<AppBarMenuItem> menuItems;

    if (deckState.isEditMode) {
      final Widget nameFieldWidget = TextField(
        controller: nameController,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: locale.translate('page_deck_builder.app_bar'),
        ),
        onChanged: (value) {
          final trimmed = value.trim();
          deckBloc.add(SetDeckNameEvent(name: trimmed.isNotEmpty ? trimmed : locale.translate('page_deck_builder.app_bar')));
        },
        onSubmitted: (_) {
          final trimmed = nameController.text.trim();
          final newName = trimmed.isNotEmpty
              ? trimmed
              : locale.translate('page_deck_builder.app_bar');

          deckBloc.add(SetDeckNameEvent(name: newName));
          nameController.text = newName;
        },
      );

      menuItems = [
        AppBarMenuItem(
          label: Icons.nfc_rounded,
          action: () {
            if (nfcBloc.state.isSessionActive) {
              nfcBloc.add(StopNfcSessionEvent());
              deckBloc.add(SelectCardEvent(card: const CardEntity()));
            } else {
              nfcBloc.add(StartNfcSessionEvent(card: deckState.selectedCard));
            }
          },
        ),
        AppBarMenuItem(
          label: Icons.delete_outline_rounded,
          action: () {
            buildCupertinoActionDialog(
              theme: theme,
              title: locale.translate('page_deck_builder.dialog_delete_title'),
              content: locale.translate('page_deck_builder.dialog_delete_content'),
              cancelButtonText: locale.translate('common.button_cancel'),
              confirmButtonText: locale.translate('common.button_confirm'),
              onPressed: () {
                deckBloc.add(DeleteDeckEvent(userId: userId, deckId: deckState.currentDeck.deckId!, locale: locale));
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
            deckBloc.add(UpdateDeckEvent(userId: userId));
            nfcBloc.add(StopNfcSessionEvent());
            deckBloc.add(CloseEditModeEvent());
          },
        ),
      ];
    } else {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.ios_share_rounded,
          action: () {
            deckBloc.add(ShareEvent(locale: locale));
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
            deckBloc.add(ToggleEditModeEvent());
            if (applicationBloc.state.tutorialNfcIcon) {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Tutorial",
                transitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => const TutorailNFCIcon(),
              );
              applicationBloc.add(UpdateSettingEvent(key: AppConfig.keyTutorial, value: false));
            }
          },
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
