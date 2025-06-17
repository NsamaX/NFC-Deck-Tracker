import 'package:nfc_deck_tracker/data/repository/join_room.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class JoinRoomUsecase {
  final JoinRoomRepository joinRoomRepository;

  JoinRoomUsecase({
    required this.joinRoomRepository,
  });

  Future<void> call({
    required String roomId,
    required String playerId,
  }) async {
    final success = await joinRoomRepository.join(
      roomId: roomId,
      playerId: playerId,
    );

    if (!success) {
      LoggerUtil.debugMessage(message: '⚠️ Failed to join room "$roomId"');
    }
  }
}
