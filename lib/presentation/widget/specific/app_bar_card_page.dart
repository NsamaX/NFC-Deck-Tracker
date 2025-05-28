import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../shared/app_bar.dart';
import '../shared/snackbar.dart';

import '../../cubit/card_cubit.dart';
import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';

class CardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;
  final CardEntity card;
  final bool isAdd;
  final bool isCustom;

  const CardAppBar({
    Key? key,
    required this.userId,
    required this.card,
    required this.isAdd,
    required this.isCustom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);
    final cardCubit = context.read<CardCubit>();
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();

    AppBarMenuItem rightItem;

    if (isAdd) {
      rightItem = AppBarMenuItem(
        label: locale.translate('page_card_detail.toggle_add'),
        action: () => _toggleAdd(context, locale, deckCubit),
      );
    } else if (isCustom) {
      final nameFilled = (cardCubit.state.card.name ?? '').trim().isNotEmpty;
      final descFilled = (cardCubit.state.card.description ?? '').trim().isNotEmpty;

      if (nameFilled && descFilled) {
        rightItem = AppBarMenuItem(
          label: locale.translate('page_card_detail.toggle_done'),
          action: () => _toggleCreate(context, locale, cardCubit),
        );
      } else {
        rightItem = AppBarMenuItem.empty();
      }
    } else if (nfcCubit.state.isSessionActive) {
      rightItem = AppBarMenuItem(
        label: nfcCubit.state.isSessionActive
            ? Icons.wifi_tethering_rounded
            : Icons.wifi_tethering_off_rounded,
        action: () => _toggleNFC(nfcCubit),
      );
    } else {
      rightItem = AppBarMenuItem.empty();
    }

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: isCustom
            ? locale.translate('page_card_detail.app_bar_custom')
            : locale.translate('page_card_detail.app_bar_card'),
      ),
      rightItem,
    ];
  }

  void _toggleAdd(BuildContext context, AppLocalization locale, DeckCubit deckCubit) {
    deckCubit.toggleAddCard(card: card, quantity: deckCubit.state.selectedCardCount);
    showAppSnackBar(context, text: locale.translate('page_card_detail.snack_bar_add'));
    Navigator.of(context).pop();
  }

  void _toggleCreate(BuildContext context, AppLocalization locale, CardCubit cardCubit) async {
    await cardCubit.createCard(userId: userId);
    showAppSnackBar(context, text: locale.translate('page_card_detail.snack_bar_add'));
  }

  void _toggleNFC(NfcCubit nfcCubit) {
    nfcCubit.startSession(
      card: card,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
