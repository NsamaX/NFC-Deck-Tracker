import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/deck/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/deck_builder.dart';
import '../widget/deck/total_card_in_deck.dart';
import '../widget/listener/writer.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/text/description_align_center.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({super.key});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPage();
}

class _DeckBuilderPage extends State<DeckBuilderPage> with RouteAware {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: context.read<DeckBloc>().state.currentDeck.name,
    );

    context.read<DeckBloc>().add(CloseEditModeEvent());
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);

    return WriterListener(
      child: BlocBuilder<DeckBloc, DeckState>(
        builder: (context, state) {
          return Scaffold(
            appBar: DeckBuilderAppBar(
              nameController: nameController,
              locale: locale,
              theme: theme,
            ),
            body: BlocBuilder<DeckBloc, DeckState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final deck = state.currentDeck;

                if (deck.cards.isEmpty) {
                  return DescriptionAlignCenter(
                    text: locale.translate('page_deck_builder.empty_message'),
                    bottomNavHeight: true,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0, top: 8.0),
                      child: TotalCardInDeck(),
                    ),
                    Expanded(
                      child: DeckOrCardGridView(
                        items: deck.cards
                            .map((e) => MapEntry(e.card, e.count))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
