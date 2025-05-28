import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nfc_deck_tracker/.injector/setup_locator.dart';

import '_argument.dart';

import '../cubit/collection_cubit.dart';
import '../locale/localization.dart';
import '../widget/shared/app_bar.dart';
import '../widget/shared/cupertino_dialog.dart';
import '../widget/shared/image_constant.dart';
import '../widget/specific/collection_list_view.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: locator<CollectionCubit>(),
      child: _CollectionPageContent(),
    );
  }
}

class _CollectionPageContent extends StatefulWidget {
  @override
  State<_CollectionPageContent> createState() => _CollectionPageContentState();
}

class _CollectionPageContentState extends State<_CollectionPageContent> {
  late final String userId;
  late final CollectionCubit collectionCubit;

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    collectionCubit = context.read<CollectionCubit>();
    collectionCubit.fetchCollection(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        menu: [
          AppBarMenuItem.back(),
          AppBarMenuItem(
            label: locale.translate('page_collection.app_bar'),
          ),
          AppBarMenuItem(
            label: locale.translate('page_collection.toggle_new'),
            action: () {
              buildCupertinoTextFieldDialog(
                title: locale.translate('page_collection.dialog_create_title'),
                cancelButtonText: locale.translate('common.button_cancel'),
                confirmButtonText: locale.translate('common.button_ok'),
                onConfirm: (value) {
                  collectionCubit.createCollection(
                    userId: userId,
                    name: value,
                  );
                },
                closeDialog: () {
                  Navigator.of(context).pop();
                },
                showDialog: (dialog) {
                  showCupertinoDialog(
                    context: context,
                    builder: (_) => dialog,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          return CollectionListViewWidget(
            collections: state.collections,
            gameKeys: ImageConstant.games.keys.toList(),
            gameImages: ImageConstant.games.values.toList(),
            isAdd: getArguments(context)['isAdd'] ?? false,
          );
        },
      ),
    );
  }
}
