import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';

import '../entity/card_in_deck.dart';
import '../mapper/card_in_deck.dart';

class FetchCardInDeckUsecase {
  final FetchCardInDeckRepository fetchCardInDeckRepository;

  FetchCardInDeckUsecase({
    required this.fetchCardInDeckRepository,
  });

  Future<List<CardInDeckEntity>> call({
    required String deckId,
  }) async {
    final localCardModels = await fetchCardInDeckRepository.fetch(deckId: deckId);
    return localCardModels.map(CardInDeckMapper.toEntity).toList();
  }
}
