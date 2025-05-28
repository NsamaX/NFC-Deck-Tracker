import '../datasource/remote/fetch_room.dart';
import '../model/record.dart';

class FetchRoomRepository {
  final FetchRoomRemoteDatasource fetchRoomRemoteDatasource;

  FetchRoomRepository({
    required this.fetchRoomRemoteDatasource,
  });

  Future<List<RecordModel>> fetchRoomRecords({
    required String roomId,
    required String playerId,
  }) async {
    return await fetchRoomRemoteDatasource.fetchRoomRecords(roomId: roomId, playerId: playerId);
  }
}
