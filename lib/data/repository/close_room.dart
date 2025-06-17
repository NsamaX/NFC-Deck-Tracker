import '../datasource/remote/close_room.dart';

class CloseRoomRepository {
  final CloseRoomRemoteDatasource closeRoomRemoteDatasource;

  CloseRoomRepository({
    required this.closeRoomRemoteDatasource,
  });

  Future<void> close({
    required String roomId,
  }) async {
    await closeRoomRemoteDatasource.close(roomId: roomId);
  }
}
