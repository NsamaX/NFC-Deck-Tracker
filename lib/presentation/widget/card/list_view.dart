import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/browse_card/bloc.dart';
import '../../locale/localization.dart';

import 'list_tile.dart';
import '../../route/arguments.dart';

class CardListView extends StatelessWidget {
  final List<CardEntity> cards;

  const CardListView({
    super.key,
    required this.cards,
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
        mode: _modeFor(context, cards[index]),
        onDelete: (cardId) => _deleteCard(context, browseCardBloc, cardId),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      cacheExtent: 1000,
    );
  }

  CardTileMode _modeFor(BuildContext context, CardEntity card) {
    if (BrowseCardArgs.of(context).onAdd) return CardTileMode.addToDeck;
    if (!GameConfig.instance.isSupported(card.collectionId)) {
      return CardTileMode.editCustom;
    }
    return CardTileMode.browse;
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
