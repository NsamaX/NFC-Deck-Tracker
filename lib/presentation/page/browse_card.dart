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
    final collectionName = args['collectionName'] ?? 'Unknown';
    final isSupported = GameConstant.isSupported(collectionId);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: locator<CardCubit>()),
        BlocProvider.value(value: locator<CollectionCubit>()),
        BlocProvider.value(
          value: locator<SearchCubit>(
            param1: isSupported ? collectionId : GameConstant.dummy,
          )..fetchCard(
              userId: userId,
              collectionId: collectionId,
              collectionName: collectionName,
            ),
        ),
      ],
      child: _BrowseCardPageContent(
        args: args,
        collectionId: collectionId,
        isSupported: isSupported,
        userId: userId,
      ),
    );
  }
}

class _BrowseCardPageContent extends StatelessWidget {
  final Map<String, dynamic> args;
  final String collectionId;
  final String userId;
  final bool isSupported;

  const _BrowseCardPageContent({
    required this.args,
    required this.collectionId,
    required this.isSupported,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final isAdd = args['isAdd'] ?? false;
    final searchCubit = context.read<SearchCubit>();

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_search.app_bar'),
          ),
          !isSupported
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
            onSearchCleared: searchCubit.resetSearch,
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
                  isAdd: isAdd,
                  userId: userId,
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
