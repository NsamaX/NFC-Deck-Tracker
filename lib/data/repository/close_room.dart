import '../datasource/remote/close_room.dart';

class CloseRoomRepository {
  final CloseRoomRemoteDatasource closeRoomRemoteDatasource;

  CloseRoomRepository({
    required this.closeRoomRemoteDatasource,
  });

  Future<void> closeRoom({
    required String roomId,
  }) async {
    await closeRoomRemoteDatasource.closeRoom(roomId: roomId);
  }
}
