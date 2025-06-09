import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../cubit/card_cubit.dart';
import '../../locale/localization.dart';

import 'list_tile.dart';

class CardListView extends StatelessWidget {
  final List<CardEntity> cards;
  final String userId;
  final bool onAdd;
  final bool onCustom;

  const CardListView({
    super.key,
    required this.cards,
    required this.userId,
    this.onAdd = false,
    this.onCustom = false,
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
      itemBuilder: (_, index) => CardListTile(
        locale: locale,
        theme: theme,
        mediaQuery: mediaQuery,
        navigator: navigator,
        card: cards[index],
        onAdd: onAdd,
        onCustom: onCustom,
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
