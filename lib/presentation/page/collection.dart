import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '@argument.dart';

import '../cubit/collection_cubit.dart';
import '../widget/shared/image_constant.dart';
import '../widget/specific/app_bar/collection_page.dart';
import '../widget/specific/collection_list_view.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late final String userId;
  late final bool onAdd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = getArguments(context);
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    onAdd = args['onAdd'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<CollectionCubit>()..fetchCollection(userId: userId),
      child: _CollectionPageContent(userId: userId, onAdd: onAdd),
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
      appBar: AppBarCollectionPage(userId: userId),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          return CollectionListView(
            gameKeys: ImageConstant.games.keys.toList(),
            gameImages: ImageConstant.games.values.toList(),
            onAdd: onAdd,
          );
        },
      ),
    );
  }
}
