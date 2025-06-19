import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../entity/card_in_deck.dart';
import '../mapper/card.dart';

class FetchCardInDeckUsecase {
  final FetchCardInDeckRepository fetchCardInDeckRepository;

  FetchCardInDeckUsecase({
    required this.fetchCardInDeckRepository,
  });

  Future<List<CardInDeckEntity>> call({
    required String deckId,
    required String collectionId,
  }) async {
    final localCardModels = await fetchCardInDeckRepository.fetch(deckId: deckId);

    List<CardEntity> remoteCardEntities = [];

    if (GameConfig.isSupported(collectionId)) {
      try {
        final gameApi = ServiceFactory.create<GameApi>(collectionId);
        for (final model in localCardModels) {
          try {
            final apiCard = await gameApi.find(model.card.cardId);
            remoteCardEntities.add(CardMapper.toEntity(apiCard));
          } catch (_) {
            LoggerUtil.debugMessage('⚠️ Card ${model.card.cardId} not found in Game API');
          }
        }
      } catch (_) {
        LoggerUtil.debugMessage('❌ Game API is not available for $collectionId');
      }
    }

    final List<CardInDeckEntity> result = [];

    for (final local in localCardModels) {
      final localEntity = CardMapper.toEntity(local.card);

      final match = remoteCardEntities.firstWhere(
        (r) => r.cardId == localEntity.cardId,
        orElse: () => localEntity,
      );

      result.add(CardInDeckEntity(
        card: match,
        count: local.count,
      ));
    }

    return result;
  }
}
