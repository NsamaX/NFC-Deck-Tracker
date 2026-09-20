import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';

import '../../bloc/deck/bloc.dart';
import '../../bloc/deck_builder/bloc.dart';
import '../../locale/localization.dart';
import '../../route/constant.dart';

class DeckItem extends StatelessWidget {
  final DeckEntity deck;

  const DeckItem({
    super.key,
    required this.deck,
  });

  @override
  Widget build(BuildContext context) {
    final isEditMode = context.read<DeckBuilderBloc>().state.isEditMode;

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
          deck.name.isEmpty ? locale.translate('common.unknown') : deck.name,
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    context.read<DeckBuilderBloc>().add(OpenDeckEvent(deck: deck));

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
    context.read<DeckBloc>().add(DeleteDeckEvent(
        userId: PresentationScope.read(context).userId, deckId: deck.deckId));
  }
}
