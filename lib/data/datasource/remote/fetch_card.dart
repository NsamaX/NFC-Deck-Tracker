import '../../model/card.dart';

import '@firestore_service.dart';

class FetchCardRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchCardRemoteDatasource(this._firestoreService);

  Future<List<CardModel>> fetch({
    required String userId,
    required String collectionId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/collections/$collectionId/cards',
    );

    return snapshot.map((doc) {
      final data = doc.data();
      return CardModel.fromJson({
        ...data,
        'cardId': doc.id,
        'collectionId': collectionId,
      });
    }).toList();
  }
}
