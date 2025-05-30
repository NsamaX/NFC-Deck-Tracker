import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cubit/deck_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/specific/app_bar_my_deck_page.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPageState();
}

class _MyDeckPageState extends State<MyDeckPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<DeckCubit>().fetchDeck(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return BlocBuilder<DeckCubit, DeckState>(
      builder: (context, state) {
        final deckItems = state.decks;
        final isLoading = state.isLoading;

        Widget body;

        if (isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (deckItems.isEmpty) {
          body = DescriptionAlignCenter(
            text: locale.translate('page_deck_list.empty_message'),
          );
        } else {
          body = DeckOrCardGridView(
            userId: userId,
            items: deckItems,
          );
        }

        return Scaffold(
          appBar: MyDeckAppBar(),
          body: body,
          bottomNavigationBar: BottomNavigationBarWidget(),
        );
      },
    );
  }
}
