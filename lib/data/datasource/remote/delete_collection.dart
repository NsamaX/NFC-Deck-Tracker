import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

import '@firestore_service.dart';

class DeleteCollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  DeleteCollectionRemoteDatasource(this._firestoreService);

  Future<bool> delete({
    required String userId,
    required String collectionId,
  }) async {
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> cardsSnapshot;
    try {
      cardsSnapshot = await _firestoreService.queryCollection(
        collectionPath: 'users/$userId/collections/$collectionId/cards',
      );
    } on RemoteUnavailableException {
      return false;
    }

    for (var cardDoc in cardsSnapshot) {
      await _firestoreService.delete(
        collectionPath: 'users/$userId/collections/$collectionId/cards',
        documentId: cardDoc.id,
      );
    }

    return await _firestoreService.delete(
      collectionPath: 'users/$userId/collections',
      documentId: collectionId,
    );
  }
}
