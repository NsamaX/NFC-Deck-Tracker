import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../../cubit/deck_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

class DeckItem extends StatelessWidget {
  final String userId;
  final DeckEntity deck;

  const DeckItem({
    super.key,
    required this.userId,
    required this.deck,
  });

  @override
  Widget build(BuildContext context) {
    final isEditMode = context.read<DeckCubit>().state.isEditMode;

    return Stack(
      children: [
        _buildDeck(context),
        if (isEditMode) _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildDeck(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(3, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          deck.name ?? locale.translate('common.unknown'),
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    await context.read<DeckCubit>().setDeck(deckId: deck.deckId!);
    final collectionId = (deck.cards?.isNotEmpty ?? false)
        ? deck.cards!.first.card.collectionId
        : GameConfig.dummy;

    await context.read<DeckCubit>().setDeck(deckId: deck.deckId!);
    context.read<DeckCubit>().fetchCardsInDeck(
      deckId: deck.deckId!,
      collectionId: collectionId!,
    );

    Navigator.of(context).pushNamed(RouteConstant.deck_builder);
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Positioned(
      top: -2,
      right: -2,
      child: GestureDetector(
        onTap: () => _onDelete(context),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.close_rounded, 
            color: Theme.of(context).appBarTheme.iconTheme?.color,
            size: 26,
          ),
        ),
      ),
    );
  }

  void _onDelete(BuildContext context) {
    context.read<DeckCubit>().deleteDeck(
      locale: AppLocalization.of(context), 
      userId: userId, 
      deckId: deck.deckId!,
    );
  }
}
