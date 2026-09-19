import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

import '../../model/collection.dart';

import 'firestore_service.dart';

class CollectionRemoteDatasource {
  final FirestoreService _firestoreService;

  CollectionRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required CollectionModel collection,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/collections',
      documentId: collection.collectionId,
      data: collection.toJsonForRemote(),
    );
  }

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

  Future<List<CollectionModel>> fetch({
    required String userId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'users/$userId/collections',
    );

    return snapshot.map((doc) {
      final data = doc.data();
      return CollectionModel.fromJson({
        ...data,
        'collectionId': doc.id,
      });
    }).toList();
  }

  Future<bool> update({
    required String userId,
    required CollectionModel collection,
  }) async {
    final collectionData = collection.toJsonForRemote()..remove('collectionId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/collections',
      documentId: collection.collectionId,
      data: collectionData,
    );
  }
}
