import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/application/bloc.dart';
import '../../bloc/deck/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../locale/localization.dart';
import '../../route/constant.dart';

import '../notification/cupertino_dialog.dart';
import '../notification/snackbar.dart';
import '../specific/tutorail_nfc_icon.dart';

import 'default.dart';
import '../../route/arguments.dart';

class DeckBuilderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController nameController;

  const DeckBuilderAppBar({
    super.key,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final deckState = context.read<DeckBloc>().state;
    final deckName = deckState.currentDeck.name;
    final hasCards = deckState.currentDeck.cards.isNotEmpty == true;
    final collectionId =
        hasCards ? deckState.currentDeck.cards.first.card.collectionId : '';

    final addCardItem = AppBarMenuItem(
      label: Icons.add_rounded,
      action: MenuAction.route(
        RouteConstant.browse_card,
        arguments: BrowseCardArgs(
          collectionId: collectionId,
          collectionName: collectionId,
          onAdd: true,
        ),
      ),
    );

    List<AppBarMenuItem> menuItems;

    if (deckState.isNewDeck && !hasCards) {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(label: deckName),
        const AppBarMenuItem(
          label: Icons.add_rounded,
          action: MenuAction.route(
            RouteConstant.collection,
            arguments: CollectionArgs(onAdd: true),
          ),
        ),
      ];
    } else if (deckState.isNewDeck) {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem.empty(),
        AppBarMenuItem(label: deckName),
        addCardItem,
        AppBarMenuItem(
          label: AppLocalization.of(context)
              .translate('page_deck_builder.toggle_save'),
          action: MenuAction.callback(() => context.read<DeckBloc>().add(
              CreateDeckEvent(userId: PresentationScope.read(context).userId))),
        ),
      ];
    } else if (deckState.isEditMode) {
      final Widget nameFieldWidget = TextField(
        controller: nameController,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: AppLocalization.of(context)
              .translate('page_deck_builder.app_bar'),
        ),
        onChanged: (value) {
          final trimmed = value.trim();
          context.read<DeckBloc>().add(SetDeckNameEvent(
              name: trimmed.isNotEmpty
                  ? trimmed
                  : AppLocalization.of(context)
                      .translate('page_deck_builder.app_bar')));
        },
        onSubmitted: (_) {
          final trimmed = nameController.text.trim();
          final newName = trimmed.isNotEmpty
              ? trimmed
              : AppLocalization.of(context)
                  .translate('page_deck_builder.app_bar');

          context.read<DeckBloc>().add(SetDeckNameEvent(name: newName));
          nameController.text = newName;
        },
      );

      menuItems = [
        AppBarMenuItem(
          label: Icons.nfc_rounded,
          action: MenuAction.callback(() {
            if (context.read<NfcBloc>().state.isSessionActive) {
              context.read<NfcBloc>().add(StopNfcSessionEvent());
              context
                  .read<DeckBloc>()
                  .add(SelectCardEvent(card: const CardEntity()));
            } else {
              context
                  .read<NfcBloc>()
                  .add(StartNfcSessionEvent(card: deckState.selectedCard));
            }
          }),
        ),
        AppBarMenuItem(
          label: Icons.delete_outline_rounded,
          action: MenuAction.callback(() {
            buildCupertinoActionDialog(
              theme: Theme.of(context),
              title: AppLocalization.of(context)
                  .translate('page_deck_builder.dialog_delete_title'),
              content: AppLocalization.of(context)
                  .translate('page_deck_builder.dialog_delete_content'),
              cancelButtonText:
                  AppLocalization.of(context).translate('common.button_cancel'),
              confirmButtonText: AppLocalization.of(context)
                  .translate('common.button_confirm'),
              onPressed: () {
                context.read<DeckBloc>().add(DeleteDeckEvent(
                    userId: PresentationScope.read(context).userId,
                    deckId: deckState.currentDeck.deckId));
                Navigator.of(context).pop();
                AppSnackBar(context,
                    text: AppLocalization.of(context)
                        .translate('page_deck_builder.snack_bar_delete'));
              },
              closeDialog: () => Navigator.of(context).pop(),
              showDialog: (dialog) =>
                  showCupertinoDialog(context: context, builder: (_) => dialog),
            );
          }),
        ),
        AppBarMenuItem(label: nameFieldWidget),
        addCardItem,
        AppBarMenuItem(
          label: AppLocalization.of(context)
              .translate('page_deck_builder.toggle_save'),
          action: MenuAction.callback(() {
            context.read<DeckBloc>().add(UpdateDeckEvent(
                userId: PresentationScope.read(context).userId));
            context.read<NfcBloc>().add(StopNfcSessionEvent());
            context.read<DeckBloc>().add(CloseEditModeEvent());
          }),
        ),
      ];
    } else {
      menuItems = [
        AppBarMenuItem.back(),
        AppBarMenuItem(
          label: Icons.ios_share_rounded,
          action: MenuAction.callback(() {
            final locale = AppLocalization.of(context);
            context.read<DeckBloc>().add(ShareEvent(
                  nameLabel:
                      locale.translate('page_deck_builder.clipboard_deck_name'),
                  totalLabel: locale
                      .translate('page_deck_builder.clipboard_total_cards'),
                ));
          }),
        ),
        AppBarMenuItem(label: deckName),
        const AppBarMenuItem(
          label: Icons.play_arrow_rounded,
          action: const MenuAction.route(RouteConstant.deck_tracker),
        ),
        AppBarMenuItem(
          label: AppLocalization.of(context)
              .translate('page_deck_builder.toggle_edit'),
          action: MenuAction.callback(() {
            context.read<DeckBloc>().add(ToggleEditModeEvent());
            if (context.read<ApplicationBloc>().state.tutorialNfcIcon) {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Tutorial",
                transitionDuration: const Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => const TutorailNFCIcon(),
              );
              context.read<ApplicationBloc>().add(UpdateSettingsEvent(
                  (s) => s.copyWith(showNfcTutorial: false)));
            }
          }),
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
