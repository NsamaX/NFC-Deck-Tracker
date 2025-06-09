import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../route/route_constant.dart';
import '../../theme/@theme.dart';

import 'card_quantity_control.dart';

class CardWidget extends StatelessWidget {
  final CardEntity card;
  final int count;

  const CardWidget({
    super.key,
    required this.card,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isEditMode = context.watch<DeckCubit>().state.isEditMode;
    final isSessionActive = context.watch<NfcCubit>().state.isSessionActive;

    return Stack(
      children: [
        _buildCardDisplay(context),
        if (isEditMode && !isSessionActive)
          CardQuantityControl(
            card: card,
            count: count,
          ),
      ],
    );
  }

  Widget _buildCardDisplay(BuildContext context) {
    final theme = Theme.of(context);

    final isEditMode = context.read<DeckCubit>().state.isEditMode;
    final selected = context.read<DeckCubit>().state.selectedCard.cardId == card.cardId;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Opacity(
          opacity: isEditMode && !selected ? 0.4 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.appBarTheme.backgroundColor,
            ),
            child: Card(
              color: theme.appBarTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCardImage(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    final isSessionActive = context.read<NfcCubit>().state.isSessionActive;

    if (isSessionActive) {
      context.read<DeckCubit>().toggleSelectCard(card: card);
      _writeTag(context);
    } else {
      Navigator.of(context).pushNamed(
        RouteConstant.card,
        arguments: {
          'collectionId': card.collectionId,
          'card': card,
          'onNFC': true,
        },
      );
    }
  }

  void _writeTag(BuildContext context) {
    final selectedCard = context.read<DeckCubit>().state.selectedCard;

    if (selectedCard.cardId != null) {
      context.read<NfcCubit>().startSession(card: selectedCard);
    }
  }

  Widget _buildCardImage(BuildContext context) {
    final imageUrl = card.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageError(context);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(context),
    );
  }

  Widget _buildImageError(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Icon(
        Icons.image_not_supported,
        size: 36,
        color: theme.colorScheme.opacityText,
      ),
    );
  }
}
