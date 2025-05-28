import 'package:nfc_deck_tracker/data/repository/find_card.dart';

import '../entity/card.dart';
import '../entity/deck.dart';
import '../entity/record.dart';
import '../mapper/card.dart';

class GetCardsFromRecordUsecase {
  final FindCardRepository findCardRepository;

  GetCardsFromRecordUsecase({
    required this.findCardRepository,
  });

  Future<List<CardEntity>> call({
    required DeckEntity deck,
    required RecordEntity record,
  }) async {
    final cards = <CardEntity>[];
    final cache = <String, CardEntity>{};

    for (final data in record.data) {
      final key = '${data.collectionId}:${data.cardId}';

      if (cache.containsKey(key)) {
        cards.add(cache[key]!);
        continue;
      }

      CardEntity? card;
      try {
        card = deck.cards?.firstWhere(
          (c) =>
              c.card.cardId == data.cardId &&
              c.card.collectionId == data.collectionId,
        ).card;
      } catch (_) {
        card = null;
      }

      if (card == null) {
        final cardModel = await findCardRepository.findLocalCard(
          collectionId: data.collectionId,
          cardId: data.cardId,
        );
        if (cardModel != null) {
          card = CardMapper.toEntity(cardModel);
        }
      }

      card ??= CardEntity(
        cardId: data.cardId,
        collectionId: data.collectionId,
        name: 'Unknown',
      );

      cache[key] = card;
      cards.add(card);
    }

    return cards;
  }
}
