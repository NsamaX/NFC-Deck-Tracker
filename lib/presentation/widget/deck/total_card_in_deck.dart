import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/deck/bloc.dart';
import '../../locale/localization.dart';

class TotalCardInDeck extends StatelessWidget {
  const TotalCardInDeck({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<DeckBloc, DeckState>(
      builder: (context, state) {
        final cardList = state.currentDeck.cards ?? [];
        final total = cardList.fold<int>(0, (sum, e) => sum + e.count);

        return Text(
          locale
              .translate('page_deck_tracker.total_cards')
              .replaceFirst('{card}', '$total'),
          style: theme.textTheme.titleMedium,
        );
      },
    );
  }
}
