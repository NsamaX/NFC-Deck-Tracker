import '@firestore_service.dart';

class CloseRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  CloseRoomRemoteDatasource(this._firestoreService);

  Future<bool> close({
    required String roomId,
  }) async {
    return await _firestoreService.delete(
      collectionPath: 'rooms',
      documentId: roomId,
    );
  }
}
