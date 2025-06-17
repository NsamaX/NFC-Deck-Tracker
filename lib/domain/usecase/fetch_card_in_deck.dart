import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/model/card.dart';
import 'package:nfc_deck_tracker/data/model/card_in_deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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

    List<CardModel> remoteCards = [];

    if (Game.isSupported(game: collectionId)) {
      try {
        final gameApi = ServiceFactory.create<GameApi>(collectionId: collectionId);
        for (final model in localCardModels) {
          try {
            final apiCard = await gameApi.find(cardId: model.card.cardId);
            remoteCards.add(apiCard);
          } catch (_) {
            LoggerUtil.debugMessage(
              message: '⚠️ Card ${model.card.cardId} not found in Game API',
            );
          }
        }
      } catch (_) {
        LoggerUtil.debugMessage(
          message: '❌ Game API is not available for $collectionId',
        );
      }
    }

    final List<CardInDeckModel> updatedCards = [];

    for (final local in localCardModels) {
      final match = remoteCards.firstWhere(
        (r) => r.cardId == local.card.cardId,
        orElse: () => local.card,
      );

      updatedCards.add(CardInDeckModel(
        card: match,
        count: local.count,
      ));
    }

    return updatedCards
        .map((c) => CardInDeckEntity(
              card: CardMapper.toEntity(c.card),
              count: c.count,
            ))
        .toList();
  }
}
