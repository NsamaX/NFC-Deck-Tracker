import '../datasource/remote/update_room.dart';
import '../model/room.dart';

class UpdateRoomRepository {
  final UpdateRoomRemoteDatasource updateRoomRemoteDatasource;

  UpdateRoomRepository({
    required this.updateRoomRemoteDatasource,
  });

  Future<bool> update({
    required String roomId,
    required RoomModel updatedRoom,
  }) async {
    return await updateRoomRemoteDatasource.update(roomId: roomId, updatedRoom: updatedRoom);
  }
}
