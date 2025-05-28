import 'package:nfc_deck_tracker/data/repository/fetch_room.dart';

import '../entity/record.dart';
import '../mapper/record.dart';

class FetchRoomUsecase {
  final FetchRoomRepository fetchRoomRepository;

  FetchRoomUsecase({
    required this.fetchRoomRepository,
  });

  Future<List<RecordEntity>> call({
    required String roomId,
    required String playerId,
  }) async {
    final models = await fetchRoomRepository.fetchRoomRecords(
      roomId: roomId,
      playerId: playerId,
    );

    return models.map(RecordMapper.toEntity).toList();
  }
}
