import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/create_deck.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/deck.dart';
import '../mapper/deck.dart';

class CreateDeckUsecase {
  final CreateDeckRepository createDeckRepository;

  CreateDeckUsecase({
    required this.createDeckRepository,
  });

  Future<void> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final String deckId = const Uuid().v4();
    final DateTime now = DateTime.now();

    final updatedDeck = deck.copyWith(
      deckId: deckId,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final remoteSuccess = await createDeckRepository.createForRemote(
        userId: userId,
        deck: DeckMapper.toModel(
          updatedDeck.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage('⚠️ Remote create failed, will fallback to local-only');
      }
    }

    final finalEntity = updatedDeck.copyWith(isSynced: synced);
    final deckModel = DeckMapper.toModel(finalEntity);
    await createDeckRepository.createForLocal(deck: deckModel);
  }
}
