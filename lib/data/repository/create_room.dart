import '../datasource/remote/create_room.dart';
import '../model/room.dart';

class CreateRoomRepository {
  final CreateRoomRemoteDatasource createRoomRemoteDatasource;

  CreateRoomRepository({
    required this.createRoomRemoteDatasource,
  });

  Future<bool> createRoom({
    required RoomModel room,
  }) async {
    return await createRoomRemoteDatasource.createRoom(room: room);
  }
}
