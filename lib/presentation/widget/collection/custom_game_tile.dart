import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:nfc_deck_tracker/domain/entity/collection.dart';

import '../../bloc/collection/bloc.dart';
import '../../locale/localization.dart';
import '../../route/route_constant.dart';

import 'slidable_delete.dart';

class CustomGameTile extends StatelessWidget {
  final CollectionEntity collection;
  final String userId;
  final bool onAdd;

  const CustomGameTile({
    super.key,
    required this.collection,
    required this.userId,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalization.of(context);
    final theme = Theme.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(collection.updatedAt!);

    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed(
        RouteConstant.browse_card,
        arguments: {
          'collectionId': collection.collectionId,
          'collectionName': collection.name,
          'onAdd': onAdd,
        },
      ),
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
        padding: const EdgeInsets.only(left: 12.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(12.0),
            bottomRight: Radius.circular(12.0),
          ),
          child: Slidable(
            key: ValueKey(collection.collectionId),
            endActionPane: buildCollectionSlidableDelete(
              context: context,
              collection: collection,
              onDelete: (collectionId) {
                context.read<CollectionBloc>().add(DeleteCollectionEvent(
                      userId: userId,
                      collectionId: collectionId,
                    ));
              },
            ),
            child: Row(
              children: [
                _buildImageBox(),
                const SizedBox(width: 12.0),
                _buildInfoText(
                  context,
                  locale.translate('page_collection.last_updated').replaceAll('{date}', formattedDate),
                ),
              ],
            ),
          ),
        ),
      ),
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
        child: const Icon(Icons.inbox_rounded, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, String formattedDate) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            collection.name,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
