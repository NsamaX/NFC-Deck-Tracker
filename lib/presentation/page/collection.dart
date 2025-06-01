import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '_argument.dart';

import '../cubit/collection_cubit.dart';
import '../widget/shared/image_constant.dart';
import '../widget/specific/app_bar/collection_page.dart';
import '../widget/specific/collection_list_view.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage();

  @override
  State<CollectionPage> createState() => _CollectionPage();
}

class _CollectionPage extends State<CollectionPage> {
  late final String userId;

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<CollectionCubit>().fetchCollection(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final args = getArguments(context);

    return Scaffold(
      appBar: AppBarCollectionPage(
        userId: userId,
      ),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          return CollectionListView(
            gameKeys: ImageConstant.games.keys.toList(),
            gameImages: ImageConstant.games.values.toList(),
            onAdd: args['onAdd'] ?? false,
          );
        },
      ),
    );
  }
}
