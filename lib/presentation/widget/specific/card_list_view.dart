import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../material/card_list_tile.dart';

import '../../cubit/card_cubit.dart';
import '../../locale/localization.dart';

class CardListWidget extends StatelessWidget {
  final List<CardEntity> cards;
  final String userId;
  final bool isAdd;
  final bool isCustom;

  const CardListWidget({
    super.key,
    required this.cards,
    required this.userId,
    this.isAdd = false,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final navigator = Navigator.of(context);
    final cardCubit = context.read<CardCubit>();

    if (cards.isEmpty) {
      return Center(
        child: Text(
          locale.translate('card.no_result'),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: cards.length,
      itemBuilder: (_, index) => CardListTileWidget(
        locale: locale,
        theme: theme,
        mediaQuery: mediaQuery,
        navigator: navigator,
        card: cards[index],
        isAdd: isAdd,
        isCustom: isCustom,
        onDelete: (cardId) => _deleteCard(cardCubit, userId, cardId),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      cacheExtent: 1000,
    );
  }

  void _deleteCard(CardCubit cubit, String userId, String cardId) {
    final card = cards.firstWhere((c) => c.cardId == cardId);
    cubit.deleteCard(userId: userId, card: card);
  }
}
