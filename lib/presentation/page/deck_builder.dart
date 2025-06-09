import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/deck_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/text/description_align_center.dart';
import '../widget/app_bar/deck_builder.dart';
import '../widget/wrapper/writer_listener.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({super.key});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPage();
}

class _DeckBuilderPage extends State<DeckBuilderPage> {
  late final TextEditingController nameController;
  late final String userId;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: context.read<DeckCubit>().state.currentDeck.name,
    );
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    context.read<DeckCubit>().closeEditMode();
  }

  @override
  void dispose() {
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return WriterListener(
      child: Scaffold(
        appBar: DeckBuilderAppBar(
          userId: userId,
          nameController: nameController,
        ),
        body: BlocBuilder<DeckCubit, DeckState>(
          builder: (context, state) {
            final deck = state.currentDeck;

            if (deck.cards?.isEmpty ?? true) {
              return DescriptionAlignCenter(
                text: locale.translate('page_deck_create.empty_message'),
                bottomNavHeight: true,
              );
            }

            return DeckOrCardGridView(
              userId: userId,
              items: deck.cards!
                  .map((e) => MapEntry(e.card, e.count))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
