import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';

import '../../locale/localization.dart';
import '../../route/route_constant.dart';

import 'slidable_action.dart';

class CardListTile extends StatelessWidget {
  final AppLocalization locale;
  final ThemeData theme;
  final MediaQueryData mediaQuery;
  final NavigatorState navigator;
  final CardEntity? card;
  final int? count;
  final bool? isDraw;
  final bool onNFC, onAdd, onCustom, isTrack, lightTheme;
  final Color? markedColor;
  final void Function(Color color)? changeCardColor;
  final void Function(String cardId)? onDelete;

  const CardListTile({
    super.key,
    required this.locale,
    required this.theme,
    required this.mediaQuery,
    required this.navigator,
    required this.card,
    this.count,
    this.isDraw,
    this.onNFC = true,
    this.onAdd = false,
    this.onCustom = false,
    this.isTrack = false,
    this.lightTheme = false,
    this.markedColor,
    this.changeCardColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (card == null) return const SizedBox();

    final systemColor = lightTheme ? Colors.black : null;
    final backgroundColor = lightTheme ? Colors.white : theme.appBarTheme.backgroundColor!;
    final markColor = markedColor ?? backgroundColor;

    return GestureDetector(
      onTap: () => navigator.pushNamed(
        RouteConstant.card,
        arguments: {
          'collectionId': card?.collectionId,
          'card': card,
          'onNFC': onNFC,
          'onAdd': onAdd,
          'onCustom': onCustom,
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6.0),
        height: 60.0,
        decoration: BoxDecoration(
          color: markColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.2),
              offset: Offset(0, 3),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12.0),
              bottomRight: Radius.circular(12.0),
            ),
            child: Slidable(
              key: ValueKey(card!.cardId ?? UniqueKey()),
              endActionPane: buildSlidableAction(
                context: context,
                isTrack: isTrack,
                card: card!,
                markedColor: markedColor,
                backgroundColor: backgroundColor,
                changeCardColor: changeCardColor,
                onDelete: onDelete,
              ),
              child: Row(
                children: [
                  _buildImage(markColor: markColor, iconColor: systemColor),
                  const SizedBox(width: 8.0),
                  Expanded(child: _buildCardInfo(color: systemColor)),
                  const SizedBox(width: 8.0),
                  if (isDraw != null) _buildIcon(up: isDraw!, color: systemColor),
                  const SizedBox(width: 4.0),
                  if (count != null) _buildCount(color: systemColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage({required Color markColor, Color? iconColor}) {
    final imageUrl = card?.imageUrl ?? '';
    final isNetwork = imageUrl.startsWith('http');

    return Container(
      width: 42.0,
      height: 42.0,
      decoration: BoxDecoration(
        color: markColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: isNetwork
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 36.0, color: iconColor),
              )
            : Image.file(
                File(imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 36.0, color: iconColor),
              ),
      ),
    );
  }

  Widget _buildCardInfo({Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          card?.name ?? locale.translate('card.no_name'),
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4.0),
        Text(
          card?.description ?? locale.translate('card.no_description'),
          style: theme.textTheme.bodySmall?.copyWith(color: color),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildIcon({required bool up, Color? color}) {
    return Icon(
      up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
      color: color,
    );
  }

  Widget _buildCount({Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 22.0),
      child: Text(
        count.toString(),
        style: theme.textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
