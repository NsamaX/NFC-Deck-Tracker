import '../repository/card.dart';

import '../entity/card.dart';
import '../entity/tag.dart';
import '../value/card_lookup_failure.dart';

class FindCardFromTagUsecase {
  final CardRepository cardRepository;

  FindCardFromTagUsecase({
    required this.cardRepository,
  });

  Future<CardEntity> call(TagEntity tag) async {
    if (tag.collectionId.isEmpty || tag.cardId.isEmpty) {
      throw const CardLookupException(CardLookupFailure.invalidTag);
    }

    final localCard = await cardRepository.findForLocal(
      collectionId: tag.collectionId,
      cardId: tag.cardId,
    );

    if (localCard != null) {
      return localCard;
    }

    final CardEntity? apiCard;
    try {
      apiCard = await cardRepository.findForApi(
          collectionId: tag.collectionId, cardId: tag.cardId);
    } catch (_) {
      throw const CardLookupException(CardLookupFailure.gameNotSupported);
    }

    if (apiCard == null) {
      throw const CardLookupException(CardLookupFailure.cardNotFound);
    }
    return apiCard;
  }
}
