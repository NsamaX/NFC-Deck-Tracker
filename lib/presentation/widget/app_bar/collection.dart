import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/collection_cubit.dart';
import '../../locale/localization.dart';

import '../notification/cupertino_dialog.dart';

import '@default.dart';

class CollectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId;

  const CollectionAppBar({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      menu: _buildMenu(context),
    );
  }

  List<AppBarMenuItem> _buildMenu(BuildContext context) {
    final locale = AppLocalization.of(context);

    return [
      AppBarMenuItem.back(),
      AppBarMenuItem(
        label: locale.translate('page_collection.app_bar'),
      ),
      AppBarMenuItem(
        label: locale.translate('page_collection.toggle_new'),
        action: () {
          buildCupertinoTextFieldDialog(
            theme: Theme.of(context),
            title: locale.translate('page_collection.dialog_create_title'),
            cancelButtonText: locale.translate('common.button_cancel'),
            confirmButtonText: locale.translate('common.button_ok'),
            onConfirm: (value) {
              context.read<CollectionCubit>().createCollection(
                userId: userId,
                name: value,
              );
            },
            closeDialog: () => Navigator.of(context).pop(),
            showDialog: (dialog) => showCupertinoDialog(
              context: context,
              builder: (_) => dialog,
            ),
          );
        },
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
