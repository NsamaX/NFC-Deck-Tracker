import 'package:nfc_deck_tracker/data/repository/find_card.dart';

import '../entity/card.dart';
import '../entity/tag.dart';
import '../mapper/card.dart';

class FindCardFromTagUsecase {
  final FindCardRepository findCardRepository;

  FindCardFromTagUsecase({
    required this.findCardRepository,
  });

  Future<CardEntity?> call(TagEntity tag) async {
    if (tag.cardId.isEmpty || tag.collectionId.isEmpty) {
      throw Exception('INVALID_TAG');
    }

    final localCard = await findCardRepository.findForLocal(
      collectionId: tag.collectionId,
      cardId: tag.cardId,
    );

    if (localCard != null) {
      return CardMapper.toEntity(localCard);
    }

    try {
      final apiCard = await findCardRepository.findForApi(collectionId: tag.collectionId, cardId: tag.cardId);
      return CardMapper.toEntity(apiCard);
    } catch (e) {
      throw Exception('GAME_NOT_SUPPORTED');
    }
  }
}
