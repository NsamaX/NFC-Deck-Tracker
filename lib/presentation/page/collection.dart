import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'argument.dart';

import '../bloc/collection/bloc.dart';
import '../widget/app_bar/collection.dart';
import '../widget/collection/list_view.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  bool? _onAdd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onAdd ??= getArguments(context)['onAdd'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = PresentationScope.read(context);
    return BlocProvider.value(
      value: dependencies.collectionBloc
        ..add(FetchCollectionEvent(userId: dependencies.userId)),
      child: _CollectionPageContent(onAdd: _onAdd!),
    );
  }
}

class _CollectionPageContent extends StatelessWidget {
  final bool onAdd;

  const _CollectionPageContent({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CollectionAppBar(),
      body: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          return CollectionListView(
            gameKeys: GameConfig.instance.availableGames,
            gameImages: GameConfig.instance.gameImagePaths,
            onAdd: onAdd,
            collections: state.collections,
          );
        },
      ),
    );
  }
}
