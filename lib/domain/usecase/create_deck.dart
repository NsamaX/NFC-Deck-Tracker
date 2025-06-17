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
    final deckModel = DeckMapper.toModel(deck);

    if (userId.isNotEmpty) {
      final remoteSuccess = await createDeckRepository.createForRemote(
        userId: userId,
        deck: deckModel,
      );

      final syncedDeck = deck.copyWith(isSynced: remoteSuccess);
      await createDeckRepository.createForLocal(
        deck: DeckMapper.toModel(syncedDeck),
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage(message: '⚠️ Remote create failed, saved as local only');
      }
    } else {
      final localOnly = deck.copyWith(isSynced: false);
      await createDeckRepository.createForLocal(
        deck: DeckMapper.toModel(localOnly),
      );
    }
  }
}
