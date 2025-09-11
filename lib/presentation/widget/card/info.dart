import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../locale/localization.dart';

class CardInfo extends StatelessWidget {
  final CardEntity card;

  const CardInfo({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.name ?? locale.translate('card.no_name'),
          style: textStyle,
        ),
        const SizedBox(height: 8.0),
        if (card.additionalData != null)
          _buildAdditionalData(context, additionalData: card.additionalData!)
        else
          Opacity(
            opacity: 0.6,
            child: Text(
              card.description ?? locale.translate('card.no_description'),
              style: textStyle,
            ),
          ),
      ],
    );
  }

  Widget _buildAdditionalData(
    BuildContext context, {
    required Map<String, dynamic> additionalData,
  }) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    final entries = additionalData.entries
        .where((e) => (e.value is String && e.value.isNotEmpty) || e.value is num)
        .map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '${e.key}: ', style: textStyle),
                    TextSpan(text: '${e.value}', style: textStyle),
                  ],
                ),
              ),
            ))
        .toList();

    return Opacity(
      opacity: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries,
      ),
    );
  }
}
