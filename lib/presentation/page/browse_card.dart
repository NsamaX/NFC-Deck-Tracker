import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '@argument.dart';

import '../cubit/search_cubit.dart';
import '../cubit/card_cubit.dart';
import '../locale/localization.dart';
import '../route/route_constant.dart';
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
    final collectionId = args['collectionId'];
    final collectionName = args['collectionName'];
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchCubit>(
          create: (_) => locator<SearchCubit>(
            param1: Game.isSupported(collectionId) ? collectionId : Game.dummy,
          )..fetchCard(
              userId: userId,
              collectionId: collectionId,
              collectionName: collectionName,
            ),
        ),
        BlocProvider<CardCubit>(
          create: (_) => locator<CardCubit>(),
        ),
      ],
      child: _BrowseCardView(args: args, userId: userId),
    );
  }
}

class _BrowseCardView extends StatelessWidget {
  final Map<String, dynamic> args;
  final String userId;

  const _BrowseCardView({required this.args, required this.userId});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_search.app_bar'),
          ),
          !Game.isSupported(args['collectionId'])
              ? AppBarMenuItem(
                  label: Icons.add_rounded,
                  action: {
                    'route': RouteConstant.card,
                    'arguments': {
                      'collectionId': args['collectionId'],
                      'onCustom': true,
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
              context.read<SearchCubit>().filterCardByName(query: query);
            },
            onSearchCleared: context.read<SearchCubit>().resetSearch,
          ),
          const SizedBox(height: 8),
          BlocBuilder<SearchCubit, SearchState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Expanded(child: Center(child: CircularProgressIndicator()));
              }

              if (state.errorMessage.isNotEmpty) {
                return Expanded(
                  child: DescriptionAlignCenter(
                    text: locale.translate(state.errorMessage),
                    bottomSpacing: UIConstant.searchBarHeight,
                    bottomNavHeight: true,
                  ),
                );
              }

              return Expanded(
                child: CardListWidget(
                  cards: state.visibleCards,
                  onAdd: args['onAdd'] ?? false,
                  userId: userId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
