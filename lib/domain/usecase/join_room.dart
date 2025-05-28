import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/join_room.dart';

class JoinRoomUsecase {
  final JoinRoomRepository joinRoomRepository;

  JoinRoomUsecase({
    required this.joinRoomRepository,
  });

  Future<void> call({
    required String roomId,
    required String playerId,
  }) async {
    final success = await joinRoomRepository.joinRoom(
      roomId: roomId,
      playerId: playerId,
    );

    if (!success) {
      debugPrint('⚠️ Failed to join room "$roomId"');
    }
  }
}
