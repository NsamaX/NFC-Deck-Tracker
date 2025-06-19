import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import '../bloc/deck/deck_bloc.dart';
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
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
    context.read<DeckBloc>().add(FetchDeckEvent(userId: userId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locator<RouteObserver<ModalRoute>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    locator<RouteObserver<ModalRoute>>().unsubscribe(this);
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
