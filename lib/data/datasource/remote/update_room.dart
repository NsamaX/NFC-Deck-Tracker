import '../../model/room.dart';

import '@firestore_service.dart';

class UpdateRoomRemoteDatasource {
  final FirestoreService _firestoreService;

  UpdateRoomRemoteDatasource(this._firestoreService);

  Future<bool> update({
    required String roomId,
    required RoomModel updatedRoom,
  }) async {
    return await _firestoreService.update(
      collectionPath: 'rooms',
      documentId: roomId,
      data: {
        'cards': updatedRoom.cards.map((e) => e.toJson()).toList(),
        'record': updatedRoom.record.toJson(),
      },
    );
  }
}
