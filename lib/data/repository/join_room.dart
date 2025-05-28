import '../datasource/remote/join_room.dart';

class JoinRoomRepository {
  final JoinRoomRemoteDatasource joinRoomRemoteDatasource;

  JoinRoomRepository({
    required this.joinRoomRemoteDatasource,
  });

  Future<bool> joinRoom({
    required String roomId,
    required String playerId,
  }) async {
    return await joinRoomRemoteDatasource.joinRoom(roomId: roomId, playerId: playerId);
  }
}
