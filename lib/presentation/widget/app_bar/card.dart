import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../cubit/card_cubit.dart';
import '../../cubit/deck_cubit.dart';
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
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();
    final cardCubit = context.watch<CardCubit>();
    final cardState = cardCubit.state.card;

    AppBarMenuItem rightItem = AppBarMenuItem.empty();

    if (onAdd) {
      rightItem = AppBarMenuItem(
        label: locale.translate('page_card_detail.toggle_add'),
        action: () {
          deckCubit.toggleAddCard(
            card: card,
            quantity: deckCubit.state.selectedCardCount,
          );
          AppSnackBar(
            context,
            text: locale.translate('page_card_detail.snack_bar_add'),
          );
          Navigator.of(context).pop();
        },
      );
    } else if (onCustom) {
      final nameFilled = (cardState.name ?? '').trim().isNotEmpty;

      if (nameFilled) {
        rightItem = AppBarMenuItem(
          label: locale.translate('page_card_detail.toggle_done'),
          action: () async {
            await context.read<CardCubit>().createCard(userId: userId, collectionId: collectionId, locale: locale);
            AppSnackBar(
              context,
              text: locale.translate('page_card_detail.snack_bar_add'),
            );
          },
        );
      }
    } else if (onNFC) {
      final isActive = nfcCubit.state.isSessionActive;
      rightItem = AppBarMenuItem(
        label: isActive
            ? Icons.wifi_tethering_rounded
            : Icons.wifi_tethering_off_rounded,
        action: () {
          isActive ? nfcCubit.stopSession() : nfcCubit.startSession(card: card);
        },
      );
    }

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: locale.translate(
          onCustom
              ? 'page_card_detail.app_bar_custom'
              : 'page_card_detail.app_bar_card',
        ),
      ),
      rightItem,
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
