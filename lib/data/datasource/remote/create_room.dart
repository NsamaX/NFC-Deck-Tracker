import '@firestore_service.dart';

import '../../model/room.dart';

class CreateRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateRoomRemoteDatasource(this._firestoreService);

  Future<bool> createRoom({
    required RoomModel room,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'rooms',
      documentId: room.roomId,
      data: room.toJson(),
    );
  }
}
