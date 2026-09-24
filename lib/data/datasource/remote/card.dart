import '../../model/card.dart';

import 'firestore_service.dart';

class CardRemoteDatasource {
  final FirestoreService _firestoreService;

  CardRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required CardModel card,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/collections/${card.collectionId}/cards',
      documentId: card.cardId,
      data: card.toJsonForRemote(),
    );
  }

  Future<bool> delete({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/collections/$collectionId/cards',
      documentId: cardId,
    );
  }

  Future<List<CardModel>> fetch({
    required String userId,
    required String collectionId,
  }) async {
    final path = 'users/$userId/collections/$collectionId/cards';
    return _firestoreService.fetchDocuments(
      collectionPath: path,
      parse: (id, data) => CardModel.fromJson(
          {...data, 'cardId': id, 'collectionId': collectionId}),
    );
  }

  Future<bool> update({
    required String userId,
    required CardModel card,
  }) async {
    final cardData = card.toJsonForRemote()
      ..remove('collectionId')
      ..remove('cardId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/collections/${card.collectionId}/cards',
      documentId: card.cardId,
      data: cardData,
    );
  }
}
