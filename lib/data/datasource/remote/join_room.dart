import '@firestore_service.dart';

class JoinRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  JoinRoomRemoteDatasource(this._firestoreService);

  Future<bool> joinRoom({
    required String roomId,
    required String playerId,
  }) async {
    return await _firestoreService.updateArrayField(
      collectionPath: 'rooms',
      documentId: roomId,
      fieldName: 'playerIds',
      valuesToAdd: [playerId],
    );
  }
}
