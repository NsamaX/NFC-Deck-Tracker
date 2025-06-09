import '../../model/record.dart';

import '@firestore_service.dart';

class FetchRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  FetchRoomRemoteDatasource(this._firestoreService);

  Future<List<RecordModel>> fetchRoomRecords({
    required String roomId,
    required String playerId,
  }) async {
    final snapshot = await _firestoreService.queryCollection(
      collectionPath: 'rooms/$roomId/records',
      queryBuilder: (query) => query.where('playerIds', arrayContains: playerId),
    );

    return snapshot.map((doc) {
      final data = doc.data();
      return RecordModel.fromJson({
        ...data,
        'recordId': doc.id,
      });
    }).toList();
  }
}
