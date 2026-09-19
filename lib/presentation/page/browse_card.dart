import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import '@argument.dart';

import '../bloc/browse_card/bloc.dart';
import '../bloc/card/bloc.dart';
import '../locale/localization.dart';
import '../route/constant.dart';
import '../widget/app_bar/@default.dart';
import '../widget/card/list_view.dart';
import '../widget/specific/search_bar.dart';
import '../widget/text/description_align_center.dart';
import '../constant.dart';

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
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = getArguments(context);
      userId = PresentationScope.read(context).session.currentUser?.uid ?? '';
      collectionId = args['collectionId'];
      collectionName = args['collectionName'];
      onAdd = args['onAdd'] ?? false;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BrowseCardBloc>(
          create: (_) => PresentationScope.read(context).createBrowseCardBloc(
            GameConfig.instance.isSupported(collectionId)
                ? collectionId
                : GameConfig.dummy,
          )..add(FetchCardEvent(
              userId: userId,
              collectionId: collectionId,
            )),
        ),
        BlocProvider<CardBloc>(
            create: (_) => PresentationScope.read(context).createCardBloc()),
      ],
      child: _BrowseCardContent(
        userId: userId,
        onAdd: onAdd,
        collectionId: collectionId,
        collectionName: collectionName,
      ),
    );
  }
}

class _BrowseCardContent extends StatefulWidget {
  final String userId;
  final bool onAdd;
  final String collectionId;
  final String collectionName;

  const _BrowseCardContent({
    required this.userId,
    required this.onAdd,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  State<_BrowseCardContent> createState() => _BrowseCardContentState();
}

class _BrowseCardContentState extends State<_BrowseCardContent>
    with RouteAware {
  RouteObserver<ModalRoute>? _routeObserver;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = PresentationScope.read(context).routeObserver;
    _routeObserver!.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (!GameConfig.instance.isSupported(widget.collectionId)) {
      context.read<BrowseCardBloc>().add(FetchCardEvent(
            userId: widget.userId,
            collectionId: widget.collectionId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: DefaultAppBar(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_browse_card.app_bar'),
          ),
          !GameConfig.instance.isSupported(widget.collectionId)
              ? AppBarMenuItem(
                  label: locale.translate('page_browse_card.toggle_create'),
                  action: {
                    'route': RouteConstant.card,
                    'arguments': {
                      'collectionId': widget.collectionId,
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
              context.read<BrowseCardBloc>().add(FilterCardEvent(query: query));
            },
            onSearchCleared: () =>
                context.read<BrowseCardBloc>().add(ClearFilterEvent()),
          ),
          const SizedBox(height: 8),
          BlocBuilder<BrowseCardBloc, BrowseCardState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              }

              if (state.errorMessage.isNotEmpty) {
                return Expanded(
                  child: DescriptionAlignCenter(
                    text: locale.translate(state.errorMessage),
                    bottomSpacing: WidgetConstant.searchBarHeight,
                    bottomNavHeight: true,
                  ),
                );
              }

              return Expanded(
                child: CardListView(
                  cards: state.visibleCards,
                  onAdd: widget.onAdd,
                  userId: widget.userId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
