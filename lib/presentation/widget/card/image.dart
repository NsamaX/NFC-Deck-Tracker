import 'dart:io';
import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../locale/localization.dart';

class CardImage extends StatelessWidget {
  final CardEntity? card;

  const CardImage({
    super.key,
    this.card,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: _buildBoxDecoration(theme),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: _buildImage(context, imageUrl: card?.imageUrl ?? ''),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, {required String imageUrl}) {
    if (imageUrl.isEmpty) return _buildErrorImage(context);

    final isNetwork = imageUrl.startsWith('http');
    final isLocal = !isNetwork && File(imageUrl).existsSync();

    if (isNetwork) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorImage(context),
      );
    } else if (isLocal) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorImage(context),
      );
    }

    return _buildErrorImage(context);
  }

  Widget _buildErrorImage(BuildContext context) {
    final locale = AppLocalization.of(context);
    return _buildPlaceholder(
      context,
      icon: Icons.image_not_supported,
      text: locale.translate('text.no_card_image'),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: Colors.grey),
          const SizedBox(height: 8.0),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.appBarTheme.backgroundColor,
      borderRadius: BorderRadius.circular(16.0),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          offset: Offset(3.0, 4.0),
          blurRadius: 12.0,
          spreadRadius: 2.0,
        ),
      ],
    );
  }
}
