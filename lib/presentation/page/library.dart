import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../cubit/collection_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/shared/description_align_center.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<CollectionCubit>(),
      child: _LibraryPageContent(),
    );
  }
}

class _LibraryPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final collectionCubit = context.read<CollectionCubit>();

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_library.app_bar'),
          ),
          AppBarMenuItem.empty(),
        ],
      ),
      body: FutureBuilder<List<CardEntity>>(
        future: collectionCubit.fetchUsedCardDistinct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];

          if (cards.isNotEmpty) {
            return DeckOrCardGridView(
              items: cards,
              userId: userId,
            );
          } else {
            return DescriptionAlignCenter(
              text: locale.translate('page_library.empty_message'),
              bottomNavHeight: true,
            );
          }
        },
      ),
    );
  }
}
