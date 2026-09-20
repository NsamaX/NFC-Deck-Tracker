import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/browse_card/bloc.dart';
import '../../locale/localization.dart';

import 'list_tile.dart';

class CardListView extends StatelessWidget {
  final List<CardEntity> cards;
  final bool onAdd;
  final bool onCustom;

  const CardListView({
    super.key,
    required this.cards,
    this.onAdd = false,
    this.onCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final browseCardBloc = context.read<BrowseCardBloc>();

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
        card: cards[index],
        onAdd: onAdd,
        onCustom: onCustom,
        onDelete: (cardId) => _deleteCard(context, browseCardBloc, cardId),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      cacheExtent: 1000,
    );
  }

  void _deleteCard(BuildContext context, BrowseCardBloc Bloc, String cardId) {
    final card = cards.firstWhere((c) => c.cardId == cardId);
    Bloc.add(DeleteCardEvent(
        userId: PresentationScope.read(context).userId,
        collectionId: card.collectionId,
        cardId: card.cardId,
        imageUrl: card.imageUrl!));
  }
}
