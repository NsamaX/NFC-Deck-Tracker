import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';
import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '_argument.dart';

import '../cubit/card_cubit.dart';
import '../cubit/collection_cubit.dart';
import '../cubit/search_cubit.dart';
import '../locale/localization.dart';
import '../route/route.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/shared/ui_constant.dart';
import '../widget/specific/card_list_view.dart';
import '../widget/specific/search_bar.dart';

class BrowseCardPage extends StatelessWidget {
  const BrowseCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = getArguments(context);
    final collectionId = args['collectionId'] as String;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<CardCubit>()),
        BlocProvider.value(value: locator<CollectionCubit>()),
        BlocProvider.value(value: locator<SearchCubit>(
            param1: !GameConstant.isSupported(collectionId) ? GameConstant.dummy : collectionId,
          )..fetchCard(
              userId: FirebaseAuth.instance.currentUser?.uid ?? '',
              collectionId: collectionId,
              collectionName: args['collectionName'] ?? 'Unknown',
            )),
      ],
      child: _BrowseCardPageContent(),
    );
  }
}

class _BrowseCardPageContent extends StatelessWidget {
  const _BrowseCardPageContent();

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    final args = getArguments(context);
    final collectionId = args['collectionId'] as String;
    final searchCubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_search.app_bar'),
          ),
          !GameConstant.isSupported(collectionId)
              ? AppBarMenuItem(
                  label: Icons.add_rounded,
                  action: {
                    'route': RouteConstant.card,
                    'arguments': {
                      'collectionId': collectionId,
                      'isCustom': true,
                    },
                  },
                )
              : AppBarMenuItem.empty(),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            onSearchChanged: (query) {
              searchCubit.filterCardByName(query: query);
            },
            onSearchCleared: () {
              searchCubit.resetSearch();
            },
          ),
          const SizedBox(height: 8),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              Widget body;

              if (state.isLoading) {
                body = const Center(child: CircularProgressIndicator());
              } else if (state.errorMessage.isNotEmpty) {
                body = DescriptionAlignCenter(
                  text: locale.translate(state.errorMessage),
                  bottomSpacing: UIConstant.searchBarHeight,
                  bottomNavHeight: true,
                );
              } else {
                body = CardListWidget(
                  cards: state.visibleCards,
                  isAdd: args['isAdd'] ?? false,
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                );
              }

              return Expanded(child: body);
            },
          ),
        ],
      ),
    );
  }
}
