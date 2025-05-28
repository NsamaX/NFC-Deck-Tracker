import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import 'card_quantity_control.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../route/route.dart';

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
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.watch<NfcCubit>();
    final isEditMode = deckCubit.state.isEditMode;
    final isSessionActive = nfcCubit.state.isSessionActive;

    return Stack(
      children: [
        _buildCardDisplay(context),
        if (isEditMode && !isSessionActive)
          CardQuantityControlWidget(
            card: card,
            count: count,
          ),
      ],
    );
  }

  Widget _buildCardDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final deckCubit = context.read<DeckCubit>();
    final isEditMode = deckCubit.state.isEditMode;
    final selected = deckCubit.state.selectedCard == card;

    return GestureDetector(
      onTap: () => _onCardTap(context),
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
                child: _buildCardImage(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    final imageUrl = card.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageError();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageError(),
    );
  }

  Widget _buildImageError() {
    return const Center(
      child: Icon(
        Icons.image_not_supported,
        size: 36,
        color: Colors.grey,
      ),
    );
  }

  void _onCardTap(BuildContext context) {
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();

    if (nfcCubit.state.isSessionActive) {
      deckCubit.toggleSelectCard(card: card);
      _writeCardToTag(context);
    } else {
      Navigator.of(context).pushNamed(
        RouteConstant.card,
        arguments: {
          'collectionId': card.collectionId,
          'card': card,
          'isNFC': true,
        },
      );
    }
  }

  void _writeCardToTag(BuildContext context) {
    final deckCubit = context.read<DeckCubit>();
    final nfcCubit = context.read<NfcCubit>();
    final selectedCard = deckCubit.state.selectedCard;

    if (selectedCard.cardId != null) {
      nfcCubit.startSession();
    }
  }
}
