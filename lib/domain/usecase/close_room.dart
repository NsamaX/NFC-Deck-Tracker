import 'package:nfc_deck_tracker/data/repository/close_room.dart';

class CloseRoomUsecase {
  final CloseRoomRepository closeRoomRepository;

  CloseRoomUsecase({
    required this.closeRoomRepository,
  });

  Future<void> call({
    required String roomId,
  }) async {
    await closeRoomRepository.closeRoom(roomId: roomId);
  }
}
