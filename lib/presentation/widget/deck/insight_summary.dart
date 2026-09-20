import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/domain/entity/record_summary.dart';

import '../../locale/localization.dart';

class DeckInsightSummary extends StatelessWidget {
  final RecordSummary summary;

  const DeckInsightSummary({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    final totalDraw = summary.totalDraw;
    final totalReturn = summary.totalReturn;
    final percentagePlayed = summary.percentagePlayed;
    final unusedCardCount = summary.unusedCardCount;

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.translate('page_deck_tracker.summerize_title'),
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.appBarTheme.iconTheme?.color),
          ),
          const SizedBox(height: 8.0),
          ...[
            locale
                .translate('page_deck_tracker.summarize_percentage_played')
                .replaceFirst(
                    '{percentage}', percentagePlayed.toStringAsFixed(1)),
            locale
                .translate('page_deck_tracker.summarize_total_action')
                .replaceFirst('{draw}', '$totalDraw')
                .replaceFirst('{return}', '$totalReturn'),
            locale
                .translate('page_deck_tracker.summarize_unused_card')
                .replaceFirst('{unused}', '$unusedCardCount'),
          ].map(
              (line) => Text('     ➜ $line', style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
