import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';
import 'package:nfc_deck_tracker/util/logger.dart';

class FirestoreService {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? storage;

  FirebaseFirestore get firestore => _firestore!;

  FirestoreService({
    required FirebaseFirestore firestore,
    required this.storage,
  }) : _firestore = firestore;

  FirestoreService.offline()
      : _firestore = null,
        storage = null;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> queryCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        queryBuilder,
  }) async {
    if (_firestore == null) {
      throw const RemoteUnavailableException('Firestore is not configured');
    }
    try {
      Query<Map<String, dynamic>> query = firestore.collection(collectionPath);
      if (queryBuilder != null) query = queryBuilder(query);

      final result = await query.get();

      LoggerUtil.i(
          'Query\nCollection: $collectionPath\nReturned: ${result.docs.length} documents');
      return result.docs;
    } catch (e) {
      LoggerUtil.e(
          'Failed to query Firestore collection "$collectionPath": $e');
      throw RemoteUnavailableException('query $collectionPath: $e');
    }
  }

  Future<List<T>> fetchDocuments<T>({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        queryBuilder,
    required T Function(String id, Map<String, dynamic> data) parse,
  }) async {
    final docs = await queryCollection(
        collectionPath: collectionPath, queryBuilder: queryBuilder);
    return parseDocuments(
      collectionPath: collectionPath,
      documents: {for (final doc in docs) doc.id: doc.data()},
      parse: parse,
    );
  }

  static List<T> parseDocuments<T>({
    required String collectionPath,
    required Map<String, Map<String, dynamic>> documents,
    required T Function(String id, Map<String, dynamic> data) parse,
  }) {
    return documents.entries.map((doc) {
      try {
        return parse(doc.key, doc.value);
      } catch (e) {
        LoggerUtil.e('Malformed document ${doc.key} in "$collectionPath": $e');
        throw RemoteUnavailableException(
            'malformed $collectionPath/${doc.key}: $e');
      }
    }).toList();
  }

  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    if (_firestore == null) {
      throw const RemoteUnavailableException('Firestore is not configured');
    }
    try {
      final doc =
          await firestore.collection(collectionPath).doc(documentId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      LoggerUtil.e(
          'Failed to get document "$documentId" in "$collectionPath": $e');
      throw RemoteUnavailableException('get $collectionPath/$documentId: $e');
    }
  }

  Future<bool> insert({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    if (_firestore == null) return false;
    try {
      await firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge));
      LoggerUtil.i(
          'Set document "$documentId" in "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.e(
          'Failed to set document "$documentId" in "$collectionPath": $e');
      return false;
    }
  }

  Future<bool> update({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    if (_firestore == null) return false;
    try {
      await firestore.collection(collectionPath).doc(documentId).update(data);
      LoggerUtil.i(
          'Updated document "$documentId" in "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.e(
          'Failed to update document "$documentId" in "$collectionPath": $e');
      return false;
    }
  }

  Future<bool> delete({
    required String collectionPath,
    required String documentId,
  }) async {
    if (_firestore == null) return false;
    try {
      await firestore.collection(collectionPath).doc(documentId).delete();
      LoggerUtil.i(
          'Deleted document "$documentId" from "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.e(
          'Failed to delete document "$documentId" from "$collectionPath": $e');
      return false;
    }
  }
}
