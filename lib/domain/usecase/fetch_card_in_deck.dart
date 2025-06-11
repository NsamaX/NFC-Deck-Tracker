import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/model/card.dart';
import 'package:nfc_deck_tracker/data/model/deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card.dart';
import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

import '../entity/deck.dart';
import '../mapper/card.dart';

class FetchCardInDeckUsecase {
  final FetchCardInDeckRepository fetchCardInDeckRepository;
  final FetchCardRepository fetchCardRepository;
  final UpdateDeckRepository updateDeckRepository;

  FetchCardInDeckUsecase({
    required this.fetchCardInDeckRepository,
    required this.fetchCardRepository,
    required this.updateDeckRepository,
  });

  Future<List<CardInDeckEntity>> call({
    required String userId,
    required String deckId,
    required String deckName,
    required String collectionId,
  }) async {
    final localCardModels = await fetchCardInDeckRepository.fetchLocalDeck(deckId: deckId);

    List<CardModel> remoteCards = [];

    if (Game.isSupported(collectionId)) {
      try {
        final gameApi = ServiceFactory.create<GameApi>(collectionId: collectionId);
        for (final model in localCardModels) {
          try {
            final apiCard = await gameApi.findCard(cardId: model.card.cardId);
            remoteCards.add(apiCard);
          } catch (_) {
            debugPrint("⚠️ ไม่พบการ์ด ${model.card.cardId} ใน GameApi");
          }
        }
      } catch (_) {
        debugPrint("❌ GameApi ไม่พร้อมสำหรับ $collectionId");
      }
    } else {
      try {
        remoteCards = await fetchCardRepository.fetchRemoteCard(
          userId: userId,
          collectionId: collectionId,
        );
      } catch (_) {
        debugPrint("⚠️ ไม่สามารถโหลดการ์ดจาก remote collection: $collectionId");
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

    final syncDeck = DeckModel(
      deckId: deckId,
      name: deckName,
      cards: updatedCards,
      isSynced: true,
      updatedAt: DateTime.now(),
    );

    await updateDeckRepository.updateLocalDeck(deck: syncDeck);

    return syncDeck.cards.map((c) => CardInDeckEntity(card: CardMapper.toEntity(c.card), count: c.count)).toList();
  }
}
