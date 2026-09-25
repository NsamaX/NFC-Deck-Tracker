import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

import '../../model/record.dart';
import '../../model/share_record.dart';

import 'firestore_service.dart';

class RecordRemoteDatasource {
  static const String sharesPath = 'shares';

  final FirestoreService _firestoreService;

  RecordRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required String userId,
    required RecordModel record,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'users/$userId/records',
      documentId: record.recordId,
      data: record.toJsonForRemote(),
    );
  }

  Future<bool> delete({
    required String userId,
    required String recordId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'users/$userId/records',
      documentId: recordId,
    );
  }

  Future<List<RecordModel>> fetch({
    required String userId,
    required String deckId,
  }) async {
    final path = 'users/$userId/records';
    return _firestoreService.fetchDocuments(
      collectionPath: path,
      queryBuilder: (query) => query.where('deckId', isEqualTo: deckId),
      parse: (id, data) => RecordModel.fromJson({...data, 'recordId': id}),
    );
  }

  Future<ShareRecordModel?> import({
    required String userId,
  }) async {
    final data = await _firestoreService.getDocument(
      collectionPath: sharesPath,
      documentId: userId,
    );
    if (data == null) return null;
    try {
      return ShareRecordModel.fromJson(data);
    } catch (e) {
      throw RemoteUnavailableException('malformed $sharesPath/$userId: $e');
    }
  }

  Future<bool> share({
    required String userId,
    required ShareRecordModel shareRecord,
  }) async {
    return await _firestoreService.insert(
      collectionPath: sharesPath,
      documentId: userId,
      data: shareRecord.toJson(),
      merge: false,
    );
  }

  Future<bool> update({
    required String userId,
    required RecordModel record,
  }) async {
    final recordData = record.toJsonForRemote()..remove('recordId');

    return await _firestoreService.update(
      collectionPath: 'users/$userId/records',
      documentId: record.recordId,
      data: recordData,
    );
  }
}
