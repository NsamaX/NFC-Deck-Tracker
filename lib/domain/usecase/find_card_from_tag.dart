import '../repository/card.dart';

import '../entity/card.dart';
import '../entity/tag.dart';

class FindCardFromTagUsecase {
  final CardRepository cardRepository;

  FindCardFromTagUsecase({
    required this.cardRepository,
  });

  Future<CardEntity?> call(TagEntity tag) async {
    if (tag.collectionId.isEmpty || tag.cardId.isEmpty) {
      throw Exception('INVALID_TAG');
    }

    final localCard = await cardRepository.findForLocal(
      collectionId: tag.collectionId,
      cardId: tag.cardId,
    );

    if (localCard != null) {
      return localCard;
    }

    try {
      final apiCard = await cardRepository.findForApi(
          collectionId: tag.collectionId, cardId: tag.cardId);

      if (apiCard == null) {
        throw Exception('CARD_NOT_FOUND');
      }

      return apiCard;
    } catch (e) {
      throw Exception('GAME_NOT_SUPPORTED');
    }
  }
}
