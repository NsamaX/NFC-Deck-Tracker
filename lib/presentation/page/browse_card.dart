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
import '../widget/app_bar/@default.dart';
import '../widget/card/list_view.dart';
import '../widget/constant/ui.dart';
import '../widget/specific/search_bar.dart';
import '../widget/text/description_align_center.dart';

class BrowseCardPage extends StatefulWidget {
  const BrowseCardPage({super.key});

  @override
  State<BrowseCardPage> createState() => _BrowseCardPageState();
}

class _BrowseCardPageState extends State<BrowseCardPage> {
  late final String userId;
  late final String collectionId;
  late final String collectionName;
  late final bool onAdd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = getArguments(context);
    userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
    collectionId = args['collectionId'];
    collectionName = args['collectionName'];
    onAdd = args['onAdd'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
      child: _BrowseCardContent(userId: userId, onAdd: onAdd, collectionId: collectionId),
    );
  }
}

class _BrowseCardContent extends StatelessWidget {
  final String userId;
  final bool onAdd;
  final String collectionId;

  const _BrowseCardContent({
    required this.userId,
    required this.onAdd,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_search.app_bar'),
          ),
          !Game.isSupported(collectionId)
              ? AppBarMenuItem(
                  label: Icons.add_rounded,
                  action: {
                    'route': RouteConstant.card,
                    'arguments': {
                      'collectionId': collectionId,
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
                child: CardListView(
                  cards: state.visibleCards,
                  onAdd: onAdd,
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
