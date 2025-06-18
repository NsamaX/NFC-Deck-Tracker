import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class FirestoreService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  FirestoreService({
    required this.firestore,
    required this.storage,
  });

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> queryCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore.collection(collectionPath);
      if (queryBuilder != null) query = queryBuilder(query);

      final result = await query.get();

      LoggerUtil.addMessage(message: '🔎 Query\nCollection: $collectionPath\nReturned: ${result.docs.length} documents');
      LoggerUtil.flushMessages();

      return result.docs;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to query Firestore collection "$collectionPath": $e');
      return [];
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      final doc = await firestore.collection(collectionPath).doc(documentId).get();
      if (!doc.exists) return null;
      return doc;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to get document "$documentId" in "$collectionPath": $e');
      return null;
    }
  }

  Future<bool> insert({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).set(data, SetOptions(merge: merge));
      LoggerUtil.debugMessage(message: '📝 Set document "$documentId" in "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to set document "$documentId" in "$collectionPath": $e');
      return false;
    }
  }

  Future<bool> update({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).update(data);
      LoggerUtil.debugMessage(message: '🔔 Updated document "$documentId" in "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to update document "$documentId" in "$collectionPath": $e');
      return false;
    }
  }

  Future<bool> updateArrayField({
    required String collectionPath,
    required String documentId,
    required String fieldName,
    required List<dynamic> valuesToAdd,
    bool remove = false,
  }) async {
    try {
      final fieldUpdate = {
        fieldName: remove
            ? FieldValue.arrayRemove(valuesToAdd)
            : FieldValue.arrayUnion(valuesToAdd),
      };

      await firestore.collection(collectionPath).doc(documentId).update(fieldUpdate);
      LoggerUtil.debugMessage(message: '${remove ? '➖ Removed' : '➕ Added'} values in "$fieldName" of "$documentId"');
      return true;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to update array field "$fieldName" in "$documentId": $e');
      return false;
    }
  }

  Future<bool> delete({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await firestore.collection(collectionPath).doc(documentId).delete();
      LoggerUtil.debugMessage(message: '🗑️ Deleted document "$documentId" from "$collectionPath" successfully');
      return true;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to delete document "$documentId" from "$collectionPath": $e');
      return false;
    }
  }

  Future<String?> uploadImage({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        LoggerUtil.debugMessage(message: '❌ File does not exist at path: $imagePath');
        return null;
      }

      final uniqueId = const Uuid().v4();
      final ext = imagePath.split('.').last;
      final ref = storage.ref().child('users/$userId/images/$uniqueId.$ext');

      try {
        final uploadTask = await ref.putFile(file);
        final snapshot = await uploadTask.ref.getDownloadURL();
        LoggerUtil.debugMessage(message: '📤 Uploaded image → $snapshot');
        return snapshot;
      } catch (e) {
        LoggerUtil.debugMessage(message: '❌ Failed to upload image: $e');
        return null;
      }
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to upload image "$imagePath": $e');
      return null;
    }
  }
}
