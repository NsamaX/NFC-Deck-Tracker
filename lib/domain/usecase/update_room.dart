import 'package:nfc_deck_tracker/data/repository/update_room.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../entity/room.dart';
import '../mapper/room.dart';

class UpdateRoomUsecase {
  final UpdateRoomRepository updateRoomRepository;

  UpdateRoomUsecase({
    required this.updateRoomRepository,
  });

  Future<void> call({
    required String roomId,
    required RoomEntity updatedRoom,
  }) async {
    final uniqueCardsMap = <String, CardEntity>{};
    for (final card in updatedRoom.cards) {
      if (card.cardId != null) {
        uniqueCardsMap[card.cardId!] = card;
      }
    }

    final uniqueCards = uniqueCardsMap.values.toList();
    final deduplicatedRoom = updatedRoom.copyWith(cards: uniqueCards);

    final success = await updateRoomRepository.update(
      roomId: roomId,
      updatedRoom: RoomMapper.toModel(deduplicatedRoom),
    );

    if (!success) {
      LoggerUtil.debugMessage('⚠️ Failed to update room "$roomId"');
    }
  }
}
