import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../material/card_list_tile.dart';

import '../../cubit/record_cubit.dart';
import '../../cubit/pin_color_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../locale/localization.dart';

class DeckTrackerViewWidget extends StatelessWidget {
  const DeckTrackerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final recordCubit = context.read<RecordCubit>();
    final pinColorState = context.watch<PinColorCubit>().state;

    return BlocBuilder<TrackerCubit, TrackerState>(
      builder: (context, state) {
        final cardList = state.currentDeck.cards ?? [];

        final total = cardList.fold<int>(0, (sum, e) => sum + e.count);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  locale
                      .translate('page_deck_tracker.total_cards')
                      .replaceFirst('{total}', '$total'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: cardList.length,
                itemBuilder: (context, index) {
                  final cardInDeck = cardList[index];
                  final card = cardInDeck.card;
                  final count = cardInDeck.count;

                  final isDraw = recordCubit.wasLastActionDraw(
                    cardId: card.cardId!,
                    collectionId: card.collectionId!,
                  );

                  return CardListTileWidget(
                    locale: locale,
                    theme: theme,
                    navigator: Navigator.of(context),
                    mediaQuery: MediaQuery.of(context),
                    card: card,
                    count: count,
                    isDraw: isDraw,
                    isNFC: false,
                    isTrack: true,
                    lightTheme: count > 0,
                    markedColor: pinColorState.pinColor[card.cardId],
                    changeCardColor: (color) {
                      context.read<PinColorCubit>().togglePinColor(
                            cardId: card.cardId!,
                            color: color,
                          );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
