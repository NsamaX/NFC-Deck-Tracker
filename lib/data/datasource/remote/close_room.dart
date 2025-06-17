import '@firestore_service.dart';

class CloseRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  CloseRoomRemoteDatasource(this._firestoreService);

  Future<void> close({
    required String roomId,
  }) async {
    await _firestoreService.delete(
      collectionPath: 'rooms',
      documentId: roomId,
    );
  }
}
