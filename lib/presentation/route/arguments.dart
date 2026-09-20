import 'package:flutter/widgets.dart';

import '../../domain/entity/card.dart';

T _argsOf<T>(BuildContext context, T fallback) {
  final args = ModalRoute.of(context)?.settings.arguments;
  return args is T ? args : fallback;
}

class CollectionArgs {
  final bool onAdd;

  const CollectionArgs({this.onAdd = false});

  static CollectionArgs of(BuildContext context) =>
      _argsOf(context, const CollectionArgs());
}

class BrowseCardArgs {
  final String collectionId;
  final String collectionName;
  final bool onAdd;

  const BrowseCardArgs({
    required this.collectionId,
    required this.collectionName,
    this.onAdd = false,
  });

  static BrowseCardArgs of(BuildContext context) => _argsOf(
      context, const BrowseCardArgs(collectionId: '', collectionName: ''));
}

class CardArgs {
  final String collectionId;
  final CardEntity card;
  final bool onNFC;
  final bool onAdd;
  final bool onCustom;

  const CardArgs({
    required this.collectionId,
    this.card = const CardEntity(),
    this.onNFC = false,
    this.onAdd = false,
    this.onCustom = false,
  });

  static CardArgs of(BuildContext context) =>
      _argsOf(context, const CardArgs(collectionId: ''));
}
