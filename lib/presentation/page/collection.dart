import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '@argument.dart';

import '../cubit/collection_cubit.dart';
import '../widget/app_bar/collection.dart';
import '../widget/collection/list_view.dart';
import '../widget/constant/image.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  String? _userId;
  bool? _onAdd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userId == null || _onAdd == null) {
      final args = getArguments(context);
      _userId = locator<FirebaseAuth>().currentUser?.uid ?? '';
      _onAdd = args['onAdd'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<CollectionCubit>()..fetchCollection(userId: _userId!),
      child: _CollectionPageContent(userId: _userId!, onAdd: _onAdd!),
    );
  }
}

class _CollectionPageContent extends StatelessWidget {
  final String userId;
  final bool onAdd;

  const _CollectionPageContent({required this.userId, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CollectionAppBar(userId: userId),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          return CollectionListView(
            gameKeys: ImageConstant.games.keys.toList(),
            gameImages: ImageConstant.games.values.toList(),
            userId: userId,
            onAdd: onAdd,
          );
        },
      ),
    );
  }
}
