import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../bloc/deck/bloc.dart';
import '../../cubit/card.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

import '@default.dart';

class CardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final String collectionId;
  final CardEntity card;
  final bool onNFC;
  final bool onAdd;
  final bool onCustom;

  const CardAppBar({
    Key? key,
    required this.userId,
    required this.collectionId,
    required this.card,
    required this.onNFC,
    required this.onAdd,
    required this.onCustom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckBloc>();
    final nfcCubit = context.read<NfcCubit>();
    final cardCubit = context.watch<CardCubit>();
    final cardState = cardCubit.state.card;

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
          action: () {
            deckCubit.add(AddCardEvent(card: card, quantity: deckCubit.state.cardQuantity));
            AppSnackBar(
              context,
              text: locale.translate('page_card_detail.snack_bar_add'),
            );
            Navigator.of(context).pop();
          },
        ),
      );
    } else if (onCustom) {
      final nameFilled = (cardState.name ?? '').trim().isNotEmpty;
      if (cardState.imageUrl != null && nameFilled) {
        menuItems.add(AppBarMenuItem.empty());
        menuItems.add(
          AppBarMenuItem(
            label: locale.translate('page_browse_card.toggle_create'),
            action: () async {
              await context.read<CardCubit>().createCard(
                    userId: userId,
                    collectionId: collectionId,
                    locale: locale,
                  );
              AppSnackBar(
                context,
                text: locale.translate('page_card_detail.snack_bar_create'),
              );
            },
          ),
        );
      } else {
        menuItems.add(AppBarMenuItem.empty());
        menuItems.add(AppBarMenuItem.empty());
      }
    } else if (onNFC) {
      final isActive = nfcCubit.state.isSessionActive;
      menuItems.add(AppBarMenuItem.empty());
      menuItems.add(
        AppBarMenuItem(
          label: isActive
              ? Icons.wifi_tethering_rounded
              : Icons.wifi_tethering_off_rounded,
          action: () {
            isActive
                ? nfcCubit.stopSession()
                : nfcCubit.startSession(card: card);
          },
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
