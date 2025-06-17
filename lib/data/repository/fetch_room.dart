import '../datasource/remote/fetch_room.dart';
import '../model/record.dart';

class FetchRoomRepository {
  final FetchRoomRemoteDatasource fetchRoomRemoteDatasource;

  FetchRoomRepository({
    required this.fetchRoomRemoteDatasource,
  });

  Future<List<RecordModel>> fetch({
    required String roomId,
    required String playerId,
  }) async {
    return await fetchRoomRemoteDatasource.fetch(roomId: roomId, playerId: playerId);
  }
}
