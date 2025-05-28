import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/deck_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/specific/app_bar_deck_builder_page.dart';
import '../widget/specific/nfc_write_tag_listener.dart';

class DeckBuilderPage extends StatefulWidget {
  const DeckBuilderPage({super.key});

  @override
  State<DeckBuilderPage> createState() => _DeckBuilderPageState();
}

class _DeckBuilderPageState extends State<DeckBuilderPage> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: context.read<DeckCubit>().state.currentDeck.name,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return NfcWriteTagListener(
      child: BlocBuilder<DeckCubit, DeckState>(
        builder: (context, state) {
          final deck = state.currentDeck;
          final isEmpty = deck.cards?.isEmpty ?? true;

          return Scaffold(
            appBar: DeckBuilderAppBar(
              userId: userId,
              nameController: nameController,
            ),
            body: isEmpty
                ? DescriptionAlignCenter(
                    text: locale.translate('page_deck_create.empty_message'),
                    bottomNavHeight: true,
                  )
                : DeckOrCardGridView(
                    userId: userId,
                    items: deck.cards!
                        .map((e) => MapEntry(e.card, e.count))
                        .toList(),
                  ),
          );
        },
      ),
    );
  }
}
