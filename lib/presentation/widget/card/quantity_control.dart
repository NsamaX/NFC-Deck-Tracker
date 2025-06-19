import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../bloc/deck_bloc.dart';

class CardQuantityControl extends StatelessWidget {
  final CardEntity card;
  final int count;

  const CardQuantityControl({
    super.key,
    required this.card,
    required this.count,
  });

  static const double _buttonSize = 24.0;
  static const double _spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Column(
        children: [
          _buildCountIndicator(context),
          const SizedBox(height: _spacing),
          _buildActionButton(
            context,
            icon: Icons.add,
            onPressed: () => context.read<DeckBloc>().add(AddCardEvent(card: card, quantity: 1))
          ),
          const SizedBox(height: _spacing),
          _buildActionButton(
            context,
            icon: Icons.remove,
            onPressed: () => context.read<DeckBloc>().add(RemoveCardEvent(card: card))
          ),
        ],
      ),
    );
  }

  Widget _buildCountIndicator(BuildContext context) {
    final theme = Theme.of(context);

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
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

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
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}
