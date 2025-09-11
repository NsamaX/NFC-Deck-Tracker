import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../bloc/collection/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/text/description_align_center.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<CollectionBloc>(),
      child: const _LibraryPageState(),
    );
  }
}

class _LibraryPageState extends StatefulWidget {
  const _LibraryPageState();

  @override
  State<_LibraryPageState> createState() => _LibraryPageContent();
}

class _LibraryPageContent extends State<_LibraryPageState> {
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
    context.read<CollectionBloc>().add(FetchUsedCardDistinctEvent(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_library.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = state.usedCardsDistinct;

          if (cards.isNotEmpty) {
            return DeckOrCardGridView(
              userId: userId,
              items: cards,
            );
          }

          return DescriptionAlignCenter(
            text: locale.translate('page_library.empty_message'),
            bottomNavHeight: true,
          );
        },
      ),
    );
  }
}
