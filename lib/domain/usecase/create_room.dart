import 'package:nfc_deck_tracker/data/repository/create_room.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
    final success = await createRoomRepository.create(
      room: RoomMapper.toModel(room),
    );

    if (!success) {
      LoggerUtil.debugMessage('⚠️ Failed to create room remotely');
    }
  }
}
