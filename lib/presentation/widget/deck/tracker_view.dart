import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/pin_card/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../cubit/record.dart';
import '../../locale/localization.dart';

import '../card/list_tile.dart';

class DeckTrackerView extends StatelessWidget {
  final RecordCubit recordCubit;

  const DeckTrackerView({
    super.key,
    required this.recordCubit,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final pinColorState = context.watch<PinCardBloc>().state;

    return BlocBuilder<TrackerBloc, TrackerState>(
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
                      .replaceFirst('{card}', '$total'),
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

                  return CardListTile(
                    locale: locale,
                    theme: theme,
                    navigator: Navigator.of(context),
                    mediaQuery: MediaQuery.of(context),
                    card: card,
                    count: count,
                    isDraw: recordCubit.wasLastActionDraw(
                      cardId: card.cardId!,
                      collectionId: card.collectionId!,
                    ),
                    onNFC: false,
                    isTrack: true,
                    lightTheme: count > 0,
                    markedColor: pinColorState.pinColor[card.cardId],
                    changeCardColor: (color) {
                      context.read<PinCardBloc>().add(PinColorEvent(
                            cardId: card.cardId!,
                            color: color,
                          ));
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
