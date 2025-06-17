import '../../model/room.dart';

import '@firestore_service.dart';

class CreateRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  CreateRoomRemoteDatasource(this._firestoreService);

  Future<bool> create({
    required RoomModel room,
  }) async {
    return await _firestoreService.insert(
      collectionPath: 'rooms',
      documentId: room.roomId,
      data: room.toJsonForRemote(),
    );
  }
}
