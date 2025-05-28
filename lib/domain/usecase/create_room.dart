import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/create_room.dart';

import '../entity/room.dart';
import '../mapper/room.dart';

class CreateRoomUsecase {
  final CreateRoomRepository createRoomRepository;

  CreateRoomUsecase({
    required this.createRoomRepository,
  });

  Future<void> call({
    required RoomEntity room,
  }) async {
    final success = await createRoomRepository.createRoom(
      room: RoomMapper.toModel(room),
    );

    if (!success) {
      debugPrint('⚠️ Failed to create room remotely');
    }
  }
}
