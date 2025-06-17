import '../datasource/remote/create_room.dart';
import '../model/room.dart';

class CreateRoomRepository {
  final CreateRoomRemoteDatasource createRoomRemoteDatasource;

  CreateRoomRepository({
    required this.createRoomRemoteDatasource,
  });

  Future<bool> createForRoom({
    required RoomModel room,
  }) async {
    return await createRoomRemoteDatasource.create(room: room);
  }
}
