import '../repository/deck.dart';

import '../entity/card_in_deck.dart';

class FetchCardInDeckUsecase {
  final DeckRepository deckRepository;

  FetchCardInDeckUsecase({
    required this.deckRepository,
  });

  Future<List<CardInDeckEntity>> call({
    required String deckId,
  }) async {
    final localCards = await deckRepository.fetchCardsInDeck(deckId: deckId);
    return localCards;
  }
}
