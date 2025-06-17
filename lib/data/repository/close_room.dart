import '../datasource/remote/close_room.dart';

class CloseRoomRepository {
  final CloseRoomRemoteDatasource closeRoomRemoteDatasource;

  CloseRoomRepository({
    required this.closeRoomRemoteDatasource,
  });

  Future<bool> close({
    required String roomId,
  }) async {
    return await closeRoomRemoteDatasource.close(roomId: roomId);
  }
}
