import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../cubit/deck_cubit.dart';

class CardQuantityControlWidget extends StatelessWidget {
  final CardEntity card;
  final int count;

  const CardQuantityControlWidget({
    super.key,
    required this.card,
    required this.count,
  });

  static const double _buttonSize = 24.0;
  static const double _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deckCubit = context.read<DeckCubit>();

    return Positioned(
      top: 0,
      right: 0,
      child: Column(
        children: [
          _buildCountIndicator(theme),
          const SizedBox(height: _spacing),
          _buildActionButton(
            theme: theme,
            icon: Icons.add,
            onPressed: () => deckCubit.toggleAddCard(card: card, quantity: 1),
          ),
          const SizedBox(height: _spacing),
          _buildActionButton(
            theme: theme,
            icon: Icons.remove,
            onPressed: () => deckCubit.toggleRemoveCard(card: card),
          ),
        ],
      ),
    );
  }

  Widget _buildCountIndicator(ThemeData theme) {
    return Container(
      width: _buttonSize,
      height: _buttonSize,
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: _buttonSize / 1.5,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
