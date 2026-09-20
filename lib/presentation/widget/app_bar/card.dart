import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/card/bloc.dart';
import '../../bloc/deck/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

import 'default.dart';
import '../../route/arguments.dart';

class CardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final CardArgs(:collectionId, :card, :onNFC, :onAdd, :onCustom) =
        CardArgs.of(context);
    final locale = AppLocalization.of(context);
    final deckBloc = context.read<DeckBloc>();
    final nfcBloc = context.read<NfcBloc>();
    final cardBloc = context.watch<CardBloc>();
    final cardState = cardBloc.state.card;

    final menuItems = <AppBarMenuItem>[
      AppBarMenuItem.back(),
      AppBarMenuItem.empty(),
      AppBarMenuItem(
        label: locale.translate(
          onCustom
              ? 'page_card_detail.app_bar_custom'
              : 'page_card_detail.app_bar_card',
        ),
      ),
    ];

    if (onAdd) {
      menuItems.add(AppBarMenuItem.empty());
      menuItems.add(
        AppBarMenuItem(
          label: locale.translate('page_card_detail.toggle_add'),
          action: MenuAction.callback(() {
            deckBloc.add(AddCardEvent(
                card: card, quantity: deckBloc.state.cardQuantity));
            AppSnackBar(
              context,
              text: locale.translate('page_card_detail.snack_bar_add'),
            );
            Navigator.of(context).pop();
          }),
        ),
      );
    } else if (onCustom) {
      final nameFilled = (cardState.name).trim().isNotEmpty;
      final isEditing = cardState.cardId.isNotEmpty;
      if (cardState.imageUrl != null && nameFilled) {
        menuItems.add(AppBarMenuItem.empty());
        menuItems.add(
          AppBarMenuItem(
            label: locale.translate(isEditing
                ? 'page_card_detail.toggle_save'
                : 'page_browse_card.toggle_create'),
            action: MenuAction.callback(() {
              final userId = PresentationScope.read(context).userId;
              if (isEditing) {
                context.read<CardBloc>().add(UpdateCardEvent(userId: userId));
              } else {
                context.read<CardBloc>().add(CreateCardEvent(
                      userId: userId,
                      collectionId: collectionId,
                      defaultDescription:
                          locale.translate('card.no_description'),
                    ));
              }
              AppSnackBar(
                context,
                text: locale.translate(isEditing
                    ? 'page_card_detail.snack_bar_save'
                    : 'page_card_detail.snack_bar_create'),
              );
            }),
          ),
        );
      } else {
        menuItems.add(AppBarMenuItem.empty());
        menuItems.add(AppBarMenuItem.empty());
      }
    } else if (onNFC) {
      final isActive = nfcBloc.state.isSessionActive;
      menuItems.add(AppBarMenuItem.empty());
      menuItems.add(
        AppBarMenuItem(
          label: isActive
              ? Icons.wifi_tethering_rounded
              : Icons.wifi_tethering_off_rounded,
          action: MenuAction.callback(() {
            isActive
                ? nfcBloc.add(StopNfcSessionEvent())
                : nfcBloc.add(StartNfcSessionEvent(card: card));
          }),
        ),
      );
    } else {
      menuItems.add(AppBarMenuItem.empty());
      menuItems.add(AppBarMenuItem.empty());
    }

    return menuItems;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
