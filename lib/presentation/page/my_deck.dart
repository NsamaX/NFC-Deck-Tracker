import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/deck/bloc.dart';
import '../locale/localization.dart';
import '../widget/app_bar/my_deck.dart';
import '../widget/shared/bottom_navigation_bar.dart';
import '../widget/shared/deck_or_card_grid_view.dart';
import '../widget/text/description_align_center.dart';

class MyDeckPage extends StatefulWidget {
  const MyDeckPage({super.key});

  @override
  State<MyDeckPage> createState() => _MyDeckPage();
}

class _MyDeckPage extends State<MyDeckPage> with RouteAware {
  RouteObserver<ModalRoute>? _routeObserver;
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = PresentationScope.read(context).session.currentUser?.uid ?? '';
    context.read<DeckBloc>().add(FetchDeckEvent(userId: userId));
  }

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
    context.read<DeckBloc>().add(CloseEditModeEvent());
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: const MyDeckAppBar(),
      body: BlocBuilder<DeckBloc, DeckState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final deck = state.decks;
          if (deck.isEmpty) {
            return DescriptionAlignCenter(
              text: locale.translate('page_deck_list.empty_message'),
            );
          }

          return DeckOrCardGridView(
            userId: userId,
            items: deck,
          );
        },
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}
