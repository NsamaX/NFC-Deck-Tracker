import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../cubit/collection_cubit.dart';
import '../locale/localization.dart';
import '../widget/app_bar/@default.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/text/description_align_center.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<CollectionCubit>(),
      child: const _LibraryPageContent(),
    );
  }
}

class _LibraryPageContent extends StatelessWidget {
  const _LibraryPageContent();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final userId = locator<FirebaseAuth>().currentUser?.uid ?? '';

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
      body: FutureBuilder<List<CardEntity>>(
        future: context.read<CollectionCubit>().fetchUsedCardDistinct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data ?? [];

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
