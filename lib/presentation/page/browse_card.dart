import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import '_argument.dart';

import '../cubit/search_cubit.dart';
import '../locale/localization.dart';
import '../route/route_constant.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/description_align_center.dart';
import '../widget/shared/ui_constant.dart';
import '../widget/specific/card_list_view.dart';
import '../widget/specific/search_bar.dart';

class BrowseCardPage extends StatefulWidget {
  const BrowseCardPage({super.key});

  @override
  State<BrowseCardPage> createState() => _BrowseCardPageState();
}

class _BrowseCardPageState extends State<BrowseCardPage> {
  bool _initialized = false;
  late Map<String, dynamic> args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      args = getArguments(context);

      context.read<SearchCubit>().fetchCard(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        collectionId: args['collectionId'],
        collectionName: args['collectionName'],
      );

      _initialized = true;
    }
  }

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
          !GameConstant.isSupported(args['collectionId'])
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
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
