import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/setting.dart';

import '../../cubit/application_cubit.dart';
import '../../route/route_constant.dart';

class CollectionItem extends StatelessWidget {
  final String collectionId;
  final String collectionName;
  final String description;
  final String? imagePath;
  final bool onAdd;

  const CollectionItem({
    super.key,
    required this.collectionId,
    required this.collectionName,
    required this.description,
    this.imagePath,
    this.onAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _goToSearchPage(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
        height: 60.0,
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              spreadRadius: 1.0,
              blurRadius: 2.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            _buildImageBox(),
            const SizedBox(width: 12.0),
            _buildInfoText(context),
          ],
        ),
      ),
    );
  }

  void _goToSearchPage(BuildContext context) {
    final applicationCubit = context.read<ApplicationCubit>();
    applicationCubit.updateSetting(
      key: Setting.keyRecentId,
      value: collectionId,
    );
    applicationCubit.updateSetting(
      key: Setting.keyRecentGame,
      value: collectionName,
    );

    Navigator.of(context).pushReplacementNamed(
      RouteConstant.browse_card,
      arguments: {
        'collectionId': collectionId,
        'collectionName': collectionName,
        'onAdd': onAdd,
      },
    );
  }

  Widget _buildImageBox() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imagePath != null
            ? Image.asset(imagePath!, fit: BoxFit.cover)
            : const Icon(Icons.inbox_rounded, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildInfoText(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            collectionName,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            description.cleanSlashComment(),
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

extension on String {
  String cleanSlashComment() => contains('//') ? split('//')[1] : this;
}
