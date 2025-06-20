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
    await joinRoomRepository.join(
      roomId: roomId,
      playerId: playerId,
    );
  }
}
