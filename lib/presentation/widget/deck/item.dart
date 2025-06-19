import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../../bloc/deck/deck_bloc.dart';
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
    final isEditMode = context.read<DeckBloc>().state.isEditMode;

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

  void _onTap(BuildContext context) {
    context.read<DeckBloc>().add(SetCurrentDeckEvent(deckId: deck.deckId!));

    context.read<DeckBloc>().add(FetchCardInDeckEvent(deckId: deck.deckId!));

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
    context.read<DeckBloc>().add(DeleteDeckEvent(userId: userId, deckId: deck.deckId!, locale: AppLocalization.of(context)));
  }
}
