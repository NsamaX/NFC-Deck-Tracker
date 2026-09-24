import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import '../bloc/browse_card/bloc.dart';
import '../bloc/card/bloc.dart';
import '../locale/localization.dart';
import '../route/constant.dart';
import '../widget/app_bar/default.dart';
import '../widget/card/list_view.dart';
import '../widget/specific/search_bar.dart';
import '../widget/text/description_align_center.dart';
import '../constant.dart';
import '../route/arguments.dart';
import '../widget/listener/error.dart';

class BrowseCardPage extends StatefulWidget {
  const BrowseCardPage({super.key});

  @override
  State<BrowseCardPage> createState() => _BrowseCardPageState();
}

class _BrowseCardPageState extends State<BrowseCardPage> {
  @override
  Widget build(BuildContext context) {
    final args = BrowseCardArgs.of(context);
    final collectionId = args.collectionId;
    return MultiBlocProvider(
      providers: [
        BlocProvider<BrowseCardBloc>(
          create: (_) => PresentationScope.read(context).createBrowseCardBloc()
            ..add(FetchCardEvent(
              userId: PresentationScope.read(context).userId,
              collectionId: collectionId,
            )),
        ),
        BlocProvider<CardBloc>(
            create: (_) => PresentationScope.read(context).createCardBloc()),
      ],
      child: ErrorListener<CardBloc, CardState>(
        errorOf: (state) => state.errorMessage,
        child: const _BrowseCardContent(),
      ),
    );
  }
}

class _BrowseCardContent extends StatefulWidget {
  const _BrowseCardContent();

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
    if (!GameConfig.instance
        .isSupported(BrowseCardArgs.of(context).collectionId)) {
      context.read<BrowseCardBloc>().add(FetchCardEvent(
            userId: PresentationScope.read(context).userId,
            collectionId: BrowseCardArgs.of(context).collectionId,
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
          !GameConfig.instance
                  .isSupported(BrowseCardArgs.of(context).collectionId)
              ? AppBarMenuItem(
                  label: locale.translate('page_browse_card.toggle_create'),
                  action: MenuAction.route(
                    RouteConstant.card,
                    arguments: CardArgs(
                      collectionId: BrowseCardArgs.of(context).collectionId,
                      onCustom: true,
                    ),
                  ),
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
                child: CardListView(cards: state.visibleCards),
              );
            },
          ),
        ],
      ),
    );
  }
}
