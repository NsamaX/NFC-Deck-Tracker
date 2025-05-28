import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';

import '../../cubit/deck_cubit.dart';
import '../../locale/localization.dart';
import '../../route/route.dart';

class DeckWidget extends StatelessWidget {
  final DeckEntity deck;
  final String userId;

  const DeckWidget({
    super.key,
    required this.deck,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final deckCubit = context.read<DeckCubit>();
    final isEditMode = deckCubit.state.isEditMode;

    return Stack(
      children: [
        _buildMainBox(context),
        if (isEditMode) _buildDeleteButton(context),
      ],
    );
  }

  Widget _buildMainBox(BuildContext context) {
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
          deck.name ?? '',
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Positioned(
      top: -2,
      right: -2,
      child: GestureDetector(
        onTap: () => _onDelete(context),
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(Icons.close_rounded, size: 26),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) async {
    final deckCubit = context.read<DeckCubit>();
    await deckCubit.setDeck(deckId: deck.deckId!);
    Navigator.of(context).pushNamed(RouteConstant.deck_builder);
  }

  void _onDelete(BuildContext context) {
    final locale = AppLocalization.of(context);
    final deckCubit = context.read<DeckCubit>();
    deckCubit.deleteDeck(userId: userId, locale: locale, deckId: deck.deckId!);
  }
}
